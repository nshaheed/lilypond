/*
  This file is part of LilyPond, the GNU music typesetter.

  Copyright (C) 2013--2015 Aleksandr Andreev <aleksandr.andreev@gmail.com>

  LilyPond is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  LilyPond is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with LilyPond.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef KIEVAN_LIGATURE_HH
#define KIEVAN_LIGATURE_HH

#include "lily-proto.hh"
#include "grob-interface.hh"

struct Kievan_ligature
{
  DECLARE_SCHEME_CALLBACK (print, (SCM));
  DECLARE_GROB_INTERFACE ();
};

#endif /* KIEVAN_LIGATURE_HH */
