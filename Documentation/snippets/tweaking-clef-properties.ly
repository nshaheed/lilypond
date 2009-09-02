%% Do not edit this file; it is automatically
%% generated from LSR http://lsr.dsi.unimi.it
%% This file is in the public domain.
\version "2.13.4"

\header {
  lsrtags = "pitches, staff-notation, tweaks-and-overrides"

%% Translation of GIT committish: b2d4318d6c53df8469dfa4da09b27c15a374d0ca
  doctitlees = "Trucaje de las propiedades de clave"
  texidoces = "
La instrucción @code{\\clef \"treble_8\"} equivale a un ajuste de
@code{clefGlyph}, @code{clefPosition} (que controla la posición
vertical de la clave), @code{middleCPosition} y
@code{clefOctavation}.  Se imprime una clave cada vez que se
modifica cualquiera de las propiedades excepto
@code{middleCPosition}.

Observe que la modificación del glifo, la posición de la clave o
su octavación, no cambian 'per se' la posición de las siguientes
notas del pentagrama: para hacer esto también se debe especificar
la posición del Do central.  Los parámetros posicionales están en
relación con la tercera línea del pentagrama, los números
positivos desplazan hacia arriba, contando una unidad por cada
línea y espacio.  El valor de @code{clefOctavation} se
establecería normalmente a 7, -7, 15 or -15, pero son válidos
otros valores.

Cuando se produce un cambio de clave en el salto de línea se
imprime la clave nueva tanto al final de la línea anterior como al
principio de la nueva, de forma predeterminada.  Si no se necesita
la clave de advertencia al final de la línea anterior, se puede
quitar estableciendo el valor de la propiedad
@code{explicitClefVisibility} de @code{Staff}, a
@code{end-of-line-invisible}.  El comportamiento predeterminado se
puede recuperar con @code{\\unset Staff.explicitClefVisibility}.

Los siguientes ejemplos muestran las posibilidades cuando se
ajustan estas propiedades manualmente.  En la primera línea, los
cambios manuales preservan el posicionamiento relativo estándar de
las claves y las notas, pero no lo hacen en la segunda línea.
"

%% Translation of GIT committish: d96023d8792c8af202c7cb8508010c0d3648899d
  doctitlede = "Eigenschaften des Schlüssels optimieren"
  texidocde = "
Der Befehl @code{\\clef \"treble_8\"} ist gleichbedeutend mit einem
expliziten Setzen der Eigenschaften von @code{clefGlyph},
@code{clefPosition} (welche die vertikale Position des Schlüssels bestimmt),
@code{middleCPosition} und @code{clefOctavation}.  Ein Schlüssel wird
ausgegeben, wenn eine der Eigenschaften außer @code{middleCPosition} sich
ändert.

Eine Änderung des Schriftzeichens (Glyph), der Schlüsselposition oder der
Oktavierung selber ändert noch nicht die Position der darauf folgenden Noten
auf dem System: das geschieht nur, wenn auch die Position des
eingestrichenen@tie{}C (middleCPosition) angegeben wird.  Die
Positionsparameter sind relativ zur Mittellinie des Systems, dabei versetzen
positive Zahlen die Position nach oben, jeweils eine Zahl für jede Linie
plus Zwischenraum.  Der @code{clefOctavation}-Wert ist normalerweise auf 7,
-7, 15 oder -15 gesetzt, aber auch andere Werte sind gültig.

Wenn ein Schlüsselwechsel an einem Zeilenwechsel geschieht, wird das neue
Symbol sowohl am Ende der alten Zeilen als auch am Anfang der neuen Zeile
ausgegeben.  Wenn der Warnungs-Schlüssel am Ende der alten Zeile nicht
erforderlich ist, kann er unterdrückt werden, indem die
@code{explicitClefVisibility}-Eigenschaft des @code{Staff}-Kontextes auf den
Wert @code{end-of-line-invisible} gesetzt wird.  Das Standardverhalten kann
mit @code{\\unset Staff.explicitClefVisibility} wieder hergestellt werden.

Die folgenden Beispiele zeigen die Möglichkeiten, wenn man diese
Eigenschaften manuell setzt.  Auf der ersten Zeile erhalten die manuellen
Änderungen die ursprüngliche relative Positionierung von Schlüssel und
Noten, auf der zweiten Zeile nicht.
"
%% Translation of GIT committish: 59968a089729d7400f8ece38d5bc98dbb3656a2b
  texidocfr = "
La commande @code{\\clef \"treble_8\"} équivaut à définir @code{clefGlyph},
@code{clefPosition} -- qui contrôle la position verticale de la clé --
@code{middleCPosition} et @code{clefOctavation}.  Une clé est imprimée
lorsque l'une de ces propriétés, hormis @code{middleCPosition}, est
modifiée. 
 Les exemples suivant font
apparaître des possibilités de réglage manuel de ces propriétés.


Modifier le glyphe, la position de la clef ou son octaviation ne
changera pas la position des notes ; il faut pour y parvenir modifier
aussi la position du do médium.  Le positionnement est relatif à la
ligne médiane, un nombre positif faisant monter, chaque ligne ou
interligne comptant pour 1.  La valeur de @code{clefOctavation} devrait
être de 7, -7, 15 ou -15, bien que rien ne vous empêche de lui affecter
une autre valeur.


Lorsqu'un changement de clef intervient en même temps qu'un saut de
ligne, la nouvelle clef est imprimer à la fois en fin de ligne et au
début de la suivante.  Vous pouvez toujours supprimer cette « clef de 
précaution » en affectant la valeur @code{end-of-line-invisible} à la
propriété @code{explicitClefVisibility} du contexte @code{Staff}.  Le
comportement par défaut sera réactivé par 
@w{@code{\\unset@tie{}Staff.explicitClefVisibility}}. 


Les exemples qui suivent illustrent les différentes possibilités de
définir ces propriétés manuellement.  Sur la première ligne, la
position relative des notes par rapport aux clefs sont préservées, ce
qui n'est pas le cas pour la deuxième ligne.

"
  doctitlefr = "Affinage des propriétés d'une clef"

  texidoc = "
The command @code{\\clef \"treble_8\"} is equivalent to setting
@code{clefGlyph}, @code{clefPosition} (which controls the vertical
position of the clef), @code{middleCPosition} and
@code{clefOctavation}. A clef is printed when any of the properties
except @code{middleCPosition} are changed.


Note that changing the glyph, the position of the clef, or the
octavation does not in itself change the position of subsequent notes
on the staff: the position of middle C must also be specified to do
this. The positional parameters are relative to the staff center line,
positive numbers displacing upwards, counting one for each line and
space. The @code{clefOctavation} value would normally be set to 7, -7,
15 or -15, but other values are valid.


When a clef change takes place at a line break the new clef symbol is
printed at both the end of the previous line and the beginning of the
new line by default. If the warning clef at the end of the previous
line is not required it can be suppressed by setting the @code{Staff}
property @code{explicitClefVisibility} to the value
@code{end-of-line-invisible}. The default behavior can be recovered
with  @code{\\unset Staff.explicitClefVisibility}.

The following examples show the possibilities when setting these
properties manually. On the first line, the manual changes preserve the
standard relative positioning of clefs and notes, whereas on the second
line, they do not.

"
  doctitle = "Tweaking clef properties"
} % begin verbatim

\layout { ragged-right = ##t }

{
  % The default treble clef
  c'1
  % The standard bass clef
  \set Staff.clefGlyph = #"clefs.F"
  \set Staff.clefPosition = #2
  \set Staff.middleCPosition = #6
  c'1
  % The baritone clef
  \set Staff.clefGlyph = #"clefs.C"
  \set Staff.clefPosition = #4
  \set Staff.middleCPosition = #4
  c'1
  % The standard choral tenor clef
  \set Staff.clefGlyph = #"clefs.G"
  \set Staff.clefPosition = #-2
  \set Staff.clefOctavation = #-7
  \set Staff.middleCPosition = #1
  c'1
  % A non-standard clef
  \set Staff.clefPosition = #0
  \set Staff.clefOctavation = #0
  \set Staff.middleCPosition = #-4
  c'1 \break

  % The following clef changes do not preserve
  % the normal relationship between notes and clefs:

  \set Staff.clefGlyph = #"clefs.F"
  \set Staff.clefPosition = #2
  c'1
  \set Staff.clefGlyph = #"clefs.G"
  c'1
  \set Staff.clefGlyph = #"clefs.C"
  c'1
  \set Staff.clefOctavation = #7
  c'1
  \set Staff.clefOctavation = #0
  \set Staff.clefPosition = #0
  c'1

  % Return to the normal clef:

  \set Staff.middleCPosition = #0
  c'1
}

