%% Do not edit this file; it is automatically
%% generated from LSR http://lsr.dsi.unimi.it
%% This file is in the public domain.
\version "2.13.4"

\header {
  lsrtags = "pitches"

%% Translation of GIT committish: b2d4318d6c53df8469dfa4da09b27c15a374d0ca
  doctitlees = "Alteraciones de estilo dodecafónico para todas las notas, incluidas las naturales"
  texidoces = "
En las obras de principios del s.XX, empezando por Schoenberg, Berg y
Webern (la \"Segunda\" escuela de Viena), cada nota de la escala de
doce tonos se debe tratar con igualdad, sin ninguna jerarquía como los
grados clásicos tonales.  Por tanto, estos compositores imprimen una
alteración accidental para cada nota, incluso en las notas naturales,
para enfatizar su nuevo enfoque de la teoría y el lenguaje musicales.

Este fragmento de código muestra cómo conseguir dichas reglas de
notación.

"

%% Translation of GIT committish: d96023d8792c8af202c7cb8508010c0d3648899d
  texidocde = "
 In Werken des fürhen 20. Jahrhundert, angefangen mit Schönberg, Berg
 und Webern (die zweite Wiener Schule), wird jeder Ton der
 Zwölftonleiter als gleichwertig erachtet, ohne hierarchische
 Ordnung.  Deshalb wird in dieser Musik für jede Note ein Versetzungszeichen
 ausgegeben, auch für unalterierte Tonhöhen, um das neue Verständnis
 der Musiktheorie und Musiksprache zu verdeutlichen.

 Dieser Schnipsel zeigt, wie derartige Notationsregeln zu erstellen sind.
 "
  doctitlede = "Versetzungszeichen für jede Note im Stil der Zwölftonmusik"
%% Translation of GIT committish: 59968a089729d7400f8ece38d5bc98dbb3656a2b
  texidocfr = "
Au début du XXème siècle, Schoenberg, Berg et Webern -- la « Seconde »
école de Vienne -- imaginèrent de donner une importance comparable aux
douze notes de la gamme chromatique, et éviter ainsi toute tonalité.
Pour ce faire, ces compositions font apparaître une altération à chaque
note, y compris un bécarre, pour mettre en exergue cette nouvelle
approche de la théorie et du langage musicaux.

Voici comment obtenir une telle notation.

"
  doctitlefr = "Le dodécaphonisme : toute note est altérée"


  texidoc = "
In early 20th century works, starting with Schoenberg, Berg and Webern
(the @qq{Second} Viennese school), every pitch in the twelve-tone scale
has to be regarded as equal, without any hierarchy such as the
classical (tonal) degrees. Therefore, these composers print one
accidental for each note, even at natural pitches, to emphasize their
new approach to music theory and language.

This snippet shows how to achieve such notation rules.

"
  doctitle = "Dodecaphonic-style accidentals for each note including naturals"
} % begin verbatim

\score {
  \new Staff {
    #(set-accidental-style 'dodecaphonic)
    c'4 dis' cis' cis'
    c'4 dis' cis' cis'
    c'4 c' dis' des'
  }
  \layout {
    \context {
      \Staff
      \remove "Key_engraver"
    }
  }
}

