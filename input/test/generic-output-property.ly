\score{
	\notes\relative c''{
  	\outputproperty #(make-type-checker 'Note_head) 
		#'extra-offset = #'(2 . 3)
  	c2
	c
	\context Score {
		\outputproperty #(make-type-checker 'Mark) 
		#'extra-offset = #'(-1 . 4)
	}
	\mark A;
	d1
	\mark;
	e
}
\paper{
	linewidth=-1.0;
	\translator {
		\ScoreContext
		\consists "Mark_engraver";
	}
}
}
