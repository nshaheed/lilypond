;;;; output-gnome.scm -- implement GNOME canvas output
;;;;
;;;;  source file of the GNU LilyPond music typesetter
;;;; 
;;;; (c)  2004 Jan Nieuwenhuizen <janneke@gnu.org>

;;; HIP -- hack in progress
;;;
;;; You need:
;;;
;;;   * guile-1.6.4 (NOT CVS)
;;;   * Rotty's g-wrap--tng, possibly Janneke's if you have libffi-3.4.
;;;
;;; see also: guile-gtk-general@gnu.org
;;;
;;; Try it
;;;
;;;   * If using GUILE CVS , then compile LilyPond with GUILE 1.6, 
;;;
;;;    PATH=/usr/bin/:$PATH ./configure --enable-config=g16  ; make conf=g16
;;;
;;;   * Install gnome/gtk development stuff and g-wrap, guile-gnome
;;;     see buildscripts/guile-gnome.sh
;;;  
;;;   * Use latin1 encoding for gnome backend, do
;;;
"
       ./configure --prefix=$(pwd) --enable-config=g16
       make -C mf conf=g16 clean
       make -C mf conf=g16 ENCODING_FILE=$(kpsewhich cork.enc)
       (cd mf/out-g16 && mkfontdir)
       xset +fp $(pwd)/mf/out-g16
"
;;;
;;;   * Setup environment
"
export GUILE_LOAD_PATH=$HOME/usr/pkg/g-wrap/share/guile/site:$HOME/usr/pkg/g-wrap/share/guile/site/g-wrap:$HOME/usr/pkg/guile-gnome/share/guile
export LD_LIBRARY_PATH=$HOME/usr/pkg/g-wrap/lib:$HOME/usr/pkg/guile-gnome/lib
export XEDITOR='/usr/bin/emacsclient --no-wait +%l:%c %f'
"
;;;  * For GNOME point-and-click, add
;;;     #(ly:set-point-and-click 'line-column)
;;;    to your .ly; just click an object on the canvas.
;;;
;;;  * Run lily:
"
lilypond-bin -fgnome input/simple-song.ly
"


;;; TODO:
;;;  * pango+feta font (see archives gtk-i18n-list@gnome.org and
;;;    lilypond-devel)
;;;    - wait for/help with pango 1.6
;;;    - convert feta to OpenType (CFF) or TrueType (fontforge?)
;;;    - hack feta20/feta20.pfa?:
;;;  * font, canvas, scaling?
;;;  * implement missing stencil functions
;;;  * implement missing commands
;;;  * user-interface, keybindings
;;;  * cleanups: (too many) global vars
;;;  * papersize, outputscale from book


;;; SCRIPT moved to buildscripts/guile-gnome.sh



(debug-enable 'backtrace)

(define-module (scm output-gnome))

(define this-module (current-module))

(use-modules
 (guile)
 (ice-9 regex)
 (srfi srfi-13)
 (lily)
 (gnome gtk)
 (gnome gtk gdk-event))

;; the name of the module will change to canvas rsn
(if (resolve-module '(gnome gw canvas))
    (use-modules (gnome gw canvas))
    (use-modules (gnome gw libgnomecanvas)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; module entry
(define-public (gnome-output-expression expr port)
  (display (dispatch expr) port))

(define (dispatch expr)
  (if (pair? expr)
      (let ((keyword (car expr)))
	(cond
	 ((eq? keyword 'some-func) "")
	 ;;((eq? keyword 'placebox) (dispatch (cadddr expr)))
	 (else
	  (if (module-defined? this-module keyword)
	      (apply (eval keyword this-module) (cdr expr))
	      (begin
		(display
		 (string-append "undefined: " (symbol->string keyword) "\n"))
		"")))))
      expr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Lily output interface --- fix silly names and docme
"
 The output interface has functions for
  * formatting stencils, and
  * output commands

 Stencils:
 beam
 bezier-sandwich
 bracket
 char
 filledbox
 text
 ...

 Commands:
 placebox
 ...


 The Bare minimum interface for \score { \notes c } } should
 implement:

    INTERFACE-output-expression
    char
    filledbox
    placebox

 and should intercept:
"

(define (dummy . foo) #f)

;; minimal intercept list:
(define output-interface-intercept
  '(comment
    define-origin
    no-origin))

(map (lambda (x) (module-define! this-module x dummy))
     output-interface-intercept)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Global vars
(define main-window #f)
(define main-scrolled #f)
(define main-canvas #f)
(define page-number 0)

(define page-stencils #f)
(define output-canvas #f)

(define system-origin '(0 . 0))

;; UGHr
(define item-locations (make-hash-table 31))
(define location #f)

(define button-height 25)
(define canvas-width 2000)
(define canvas-height 4000)

(define window-width 400)
(define window-height
  (inexact->exact (round (* 1.42 window-width))))

(define font-paper #f)

(define pixels-per-unit 2.0)
(define OUTPUT-SCALE 2.83464566929134)
(define output-scale (* OUTPUT-SCALE pixels-per-unit))

;; helper functions -- sort this out
(define (stderr string . rest)
  ;; debugging
  (if #f
      (begin
	(apply format (cons (current-error-port) (cons string rest)))
	(force-output (current-error-port)))))

(define (utf8 i)
  (cond
   ((< i #x80) (make-string 1 (integer->char i)))
   ((< i #x800) (list->string
		 (map integer->char
		      (list (+ #xc0 (quotient i #x40))
			    (+ #x80 (modulo i #x40))))))
   ((< i #x10000)
    (let ((x (quotient i #x1000))
	  (y (modulo i #x1000)))
      (list->string
       (map integer->char
	    (list (+ #xe0 x)
		  (+ #x80 (quotient y #x40))
		  (+ #x80 (modulo y #x40)))))))
   (else FIXME)))
  
(define (custom-utf8 i)
  (if (< i 80)
      (utf8 i)
      (utf8 (+ #xee00 i))))

;;; hmm?
(define (draw-rectangle x1 y1 x2 y2 color width-units)
  (make <gnome-canvas-rect>
    #:parent (root main-canvas) #:x1 x1 #:y1 y1 #:x2 x2 #:y2 y2
    #:fill-color color #:width-units width-units))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; stencil outputters
;;;;

(define (char font i)
  (text font (utf8 i)))

(define (placebox x y expr)
  (stderr "item: ~S\n" expr)
  (let ((item expr))
    ;;(if item
    ;; FIXME ugly hack to skip #unspecified ...
    (if (and item (not (eq? item (if #f #f))))
	(begin
	  (move item
		(* output-scale (+ (car system-origin) x))
		(* output-scale (- (car system-origin) y)))
	  (affine-relative item output-scale 0 0 output-scale 0 0)
	  
	  (gtype-instance-signal-connect item 'event item-event)
	  (if location
	      (hashq-set! item-locations item location))
	  item)
	#f)))

(define (round-filled-box breapth width depth height blot-diameter)
  ;; FIXME: no rounded corners on rectangle...
  ;; FIXME: blot?
  (draw-rectangle (- breapth) depth width (- height) "black" blot-diameter))

(define (pango-font-name font)
  (cond
   ((equal? (ly:font-name font) "GNU-LilyPond-feta-20")
    "lilypond-feta, regular 32")
   (else
    (ly:font-name font))))

(define (pango-font-size font)
  (let* ((designsize (ly:font-design-size font))
	 (magnification (* (ly:font-magnification font)))
	 ;;(ops (ly:paper-lookup paper 'outputscale))
	 ;;(ops (* pixels-per-unit OUTPUT-SCALE))
	 ;;(ops (* pixels-per-unit pixels-per-unit))
	 (ops (* (/ 12 20) (* pixels-per-unit pixels-per-unit)))
	 (scaling (* ops magnification designsize)))
    scaling))

(define (text font string)
  (stderr "font-name: ~S\n" (ly:font-name font))
  ;; TODO s/filename/file-name/
  (stderr "font-filename: ~S\n" (ly:font-filename font))
  
  (stderr "pango-font-name: ~S\n" (pango-font-name font))
  (stderr "pango-font-size: ~S\n" (pango-font-size font))
  (set!
   text-items
   (cons
    (make <gnome-canvas-text>
      #:parent (root main-canvas)
      #:x 0 #:y 0
      #:font (pango-font-name font)
      #:size-points (pango-font-size font)
      #:size-set #t

      ;;apparently no effect :-(
      ;;#:scale 1.0
      ;;#:scale-set #t
      
      #:fill-color "black"
      #:text string
      #:anchor 'west)
    text-items))
  (car text-items))

(define (filledbox a b c d)
  (round-filled-box a b c d 0.001))

;; WTF is this in every backend?
(define (horizontal-line x1 x2 thickness)
  ;;(let ((thickness 2))
  (filledbox (- x1) (- x2 x1) (* .5 thickness) (* .5 thickness)))

;; origin -- bad name
(define (define-origin file line col)
  ;; ughr, why is this not passed as [part of] stencil object
  (set! location (if (procedure? point-and-click)
		     ;; duh, only silly string append
		     ;; (point-and-click line col file)
		     (list line col file)
		     #f)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; gnome stuff  --- move to framework-gnome
(define (dump-page number)
  (if (or (not page-stencils)
	  (< number 0)
	  (>= number (vector-length page-stencils)))
      (stderr "No such page: ~S\n" (1+ number))
      
      (let* ((old-canvas main-canvas)
	     (canvas (new-canvas)))
	(set! page-number number)
	
	;; no destroy method for gnome-canvas-text?
	;;(map destroy (gtk-container-get-children main-canvas))
	;;(map destroy text-items)

	;;Hmm
	;;(set! main-canvas canvas)
	(set! text-items '())
	(ly:outputter-dump-stencil output-canvas
				   (vector-ref page-stencils page-number))
	
	(if old-canvas (destroy old-canvas))
	(add main-scrolled canvas)
	(show canvas))))

(define x-editor #f)
(define (get-x-editor)
  (if (not x-editor)
      (set! x-editor (getenv "XEDITOR")))
  x-editor)

(define ifs #f)
(define (get-ifs)
  (if (not ifs)
      (set! ifs (getenv "IFS")))
  (if (not ifs)
      (set! ifs " 	"))
  ifs)
      
(define (spawn-editor location)
  (let* ((line (car location))
	 (column (cadr location))
	 (file-name (caddr location))
	 (template (substring (get-x-editor) 0))
	 
	 ;; Adhere to %l %c %f?
	 (command
	  (regexp-substitute/global
	   #f "%l" (regexp-substitute/global
		    #f "%c"
		    (regexp-substitute/global
		     #f "%f" template 'pre file-name 'post)
		    'pre (number->string column)
		    'post)
	   'pre (number->string line) 'post)))
    
    (stderr "spawning: ~s\n" command)
    (if (= (primitive-fork) 0)
	(let ((command-list (string-split command #\ )));; (get-ifs))))
	  (apply execlp command-list)
	  (primitive-exit)))))
	  
(define location-callback spawn-editor)

(define (item-event item event . data)
  (case (gdk-event:type event)
    ((enter-notify) (gobject-set-property item 'fill-color "red"))
    ((leave-notify) (gobject-set-property item 'fill-color "black"))
    ((button-press)
     (let ((location (hashq-ref item-locations item #f)))
       (if location
	   (location-callback location)
	   (stderr "no location\n"))))
    ((2button-press) (gobject-set-property item 'fill-color "red")))
  #t)

;; TODO: one list per-page
(define text-items '())
(define (scale-canvas factor)
  (set! pixels-per-unit (* pixels-per-unit factor))
  (set-pixels-per-unit main-canvas pixels-per-unit)
  (for-each
   (lambda (x)
     (let ((scale (gobject-get-property x 'scale))
	   (points (gobject-get-property x 'size-points)))
       ;;(gobject-set-property x 'scale pixels-per-unit)
       (gobject-set-property x 'size-points (* points factor))))
     text-items))

(define (key-press-event item event . data)
  (let ((keyval (gdk-event-key:keyval event))
	(mods (gdk-event-key:modifiers event)))
    (cond ((and (or (eq? keyval gdk:q)
		    (eq? keyval gdk:w))
		(equal? mods '(control-mask modifier-mask)))
	   (gtk-main-quit))
	  ((and #t ;;(null? mods)
		(eq? keyval gdk:plus))
	   (scale-canvas 2))
	  ((and #t ;; (null? mods)
		(eq? keyval gdk:minus))
	   (scale-canvas 0.5))
	  ((or (eq? keyval gdk:Page-Up)
	       (eq? keyval gdk:BackSpace))
	   (dump-page (1- page-number)))
	  ((or (eq? keyval gdk:Page-Down)
	       (eq? keyval gdk:space))
	   (dump-page (1+ page-number))))
    #f))

(define (papersize window paper)
  (let* ((hsize (ly:output-def-lookup paper 'hsize))
	 (vsize (ly:output-def-lookup paper 'vsize))
	 (width (inexact->exact (ceiling (* output-scale hsize))))
	 (height (inexact->exact (ceiling (* output-scale vsize))))
	 (max-width (gdk-screen-width))
	 (max-height (gdk-screen-height))
	 (scrollbar-size 20))

    ;; ughr: panels?
    (set! max-height (- max-height 80))

    ;; hmm?
    ;;(set! OUTPUT-SCALE (ly:bookpaper-outputscale paper))
    ;;(set! output-scale (* OUTPUT-SCALE pixels-per-unit))

    ;; huh, *2?
    
    (set! window-width (min (+ scrollbar-size (* width 2)) max-width))
    (set! window-height (min (+ button-height scrollbar-size (* height 2))
			     max-height))
    
    (set! canvas-width width)
    (set! canvas-height height)))


(define (new-canvas)
  (let* ((canvas (make <gnome-canvas>))
	 (root (root canvas)))
    
    (set-size-request canvas window-width window-height)
    (set-scroll-region canvas 0 0 canvas-width canvas-height)
    
    (set-pixels-per-unit canvas pixels-per-unit)

    (set! main-canvas canvas)
    (draw-rectangle 0 0 canvas-width canvas-height "white" 0)
    
    canvas))

(define (main outputter bookpaper pages)
  (let* ((window (make <gtk-window> #:type 'toplevel))
	 (button (make <gtk-button> #:label "Exit"))
	 (next (make <gtk-button> #:label "Next"))
	 (prev (make <gtk-button> #:label "Previous"))
	 (vbox (make <gtk-vbox> #:homogeneous #f))
	 (hbox (make <gtk-hbox> #:homogeneous #f))
	 (scrolled (make <gtk-scrolled-window>))
	 (canvas (new-canvas)))

    (papersize window bookpaper)
    (set-size-request window window-width window-height)
    
    (add window vbox)
    (add vbox scrolled)
    (add scrolled canvas)
    
    (add vbox hbox)
    (set-size-request hbox window-width button-height)
    (set-child-packing vbox hbox #f #f 0 'end)
    
    (set-child-packing hbox button #f #f 0 'end)
    (set-size-request button (quotient window-width 2) button-height)
    
    (add hbox next)
    (add hbox prev)
    (add hbox button)
    
    (gtype-instance-signal-connect button 'clicked
				   (lambda (b) (gtk-main-quit)))
    (gtype-instance-signal-connect next 'clicked
				   (lambda (b) (dump-page (1+ page-number))))
    (gtype-instance-signal-connect prev 'clicked
				   (lambda (b) (dump-page (1- page-number))))

    (gtype-instance-signal-connect window 'key-press-event key-press-event)
    (show-all window)

    ;; HMMM.  Make some class for these vars?
    (set! main-window window)
    (set! main-scrolled scrolled)
    (set! output-canvas outputter)
    (set! page-stencils pages)
    
    (dump-page 0)
    
    (gtk-main)))

