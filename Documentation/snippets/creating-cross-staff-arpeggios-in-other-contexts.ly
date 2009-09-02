%% Do not edit this file; it is automatically
%% generated from LSR http://lsr.dsi.unimi.it
%% This file is in the public domain.
\version "2.13.4"

\header {
  lsrtags = "expressive-marks"

%% Translation of GIT committish: b2d4318d6c53df8469dfa4da09b27c15a374d0ca
  texidoces = "
Se pueden crear arpegios que se cruzan entre pentagramas dentro de
contextos distintos a @code{PianoStaff} si se incluye el grabador
@code{Span_arpeggio_engraver} en el contexto de @code{Score}.

"
  doctitlees = "Creación de arpegios que se cruzan entre pentagramas dentro de otros contextos"

%% Translation of GIT committish: d96023d8792c8af202c7cb8508010c0d3648899d
 texidocde = "
In einem Klaviersystem (@code{PianoStaff}) ist es möglich, ein Arpeggio
zwischen beiden Systemen zu verbinden, indem die
@code{PianoStaff.connectArpeggios}-Eigenschaft gesetzt wird.


"
  doctitlede = "Arpeggio zwischen Systemen in einem Klaviersystem erstellen"
%% Translation of GIT committish: ae814f45737bd1bdaf65b413a4c37f70b84313b7
  texidocfr = "
Il est possible de distribuer un arpège sur plusieurs portées d'un
système autre que le @code{PianoStaff} dès lors que vous incluez le
@code{Span_arpeggio_engraver} au contexte @code{Score}.

"
  doctitlefr = "Arpège distribué pour un autre contexte que le piano"


  texidoc = "
Cross-staff arpeggios can be created in contexts other than
@code{PianoStaff} if the @code{Span_arpeggio_engraver} is included in
the @code{Score} context.

"
  doctitle = "Creating cross-staff arpeggios in other contexts"
} % begin verbatim

\score {
  \new StaffGroup {
    \set Score.connectArpeggios = ##t
    <<
      \new Voice \relative c' {
        <c e>2\arpeggio
        <d f>2\arpeggio
        <c e>1\arpeggio
      }
      \new Voice  \relative c {
        \clef bass
         <c g'>2\arpeggio
         <b g'>2\arpeggio
         <c g'>1\arpeggio
      }
    >>
  }
  \layout {
    \context {
      \Score
      \consists "Span_arpeggio_engraver"
    }
  }
}

