/*
  my-lily-lexer.cc -- implement My_lily_lexer

  source file of the GNU LilyPond music typesetter

  (c)  1997--1998 Han-Wen Nienhuys <hanwen@cs.uu.nl>
*/

#include <strstream.h>
#include <ctype.h>
#include "notename-table.hh"
#include "interval.hh"
#include "identifier.hh"
#include "assoc-iter.hh"
#include "parser.hh"
#include "keyword.hh"
#include "assoc.hh"
#include "my-lily-lexer.hh"
#include "debug.hh"
#include "source-file.hh"
#include "parseconstruct.hh"
#include "main.hh"
#include "scope.hh"

static Keyword_ent the_key_tab[]={
  {"absdynamic", ABSDYNAMIC},
  {"accepts", ACCEPTS},
  {"bar", BAR},
  {"cadenza", CADENZA},
  {"clear", CLEAR},
  {"clef", CLEF},
  {"cm", CM_T},
  {"consists", CONSISTS},
  {"contains", CONTAINS},
  {"duration", DURATION},
  {"font", FONT},
  {"grouping", GROUPING},
  {"in", IN_T},
  {"lyric", LYRIC},
  {"key", KEY},
  {"keysignature", KEYSIGNATURE},
  {"mark", MARK},
  {"melodic" , MELODIC},
  {"musicalpitch", MUSICAL_PITCH},
  {"time", TIME_T},
  {"midi", MIDI},
  {"mm", MM_T},
  {"multi", MULTI},
  {"header", HEADER},
  {"notenames", NOTENAMES},
  {"octave", OCTAVE},
  {"output", OUTPUT},
  {"partial", PARTIAL},
  {"paper", PAPER},
  {"penalty", PENALTY},
  {"property", PROPERTY},
  {"pt", PT_T},
  {"relative", RELATIVE},
  {"score", SCORE},
  {"script", SCRIPT},
  {"shape", SHAPE},
  {"skip", SKIP},
  {"staff", STAFF},
  {"table", TABLE},
  {"spandynamic", SPANDYNAMIC},
  {"symboltables", SYMBOLTABLES},
  {"tempo", TEMPO},
  {"translator", TRANSLATOR},
  {"type", TYPE},
  {"transpose", TRANSPOSE},
  {"version", VERSION},
  {0,0}
};

My_lily_lexer::My_lily_lexer()
{
  keytable_p_ = new Keyword_table (the_key_tab);
  toplevel_scope_p_ = new Scope;
  scope_l_arr_.push (toplevel_scope_p_);
  errorlevel_i_ = 0;
  note_tab_p_ = new Notename_table;
}

int
My_lily_lexer::lookup_keyword (String s)
{
  return keytable_p_->lookup (s.ch_C ());
}

Identifier*
My_lily_lexer::lookup_identifier (String s)
{
  for (int i = scope_l_arr_.size (); i--; )
    if (scope_l_arr_[i]->elt_b (s))
      return (*scope_l_arr_[i])[s];
  return 0;
}

void
My_lily_lexer::start_main_input ()
{  
  if (!monitor->silent_b ("InitDeclarations") && check_debug)
    print_declarations (true);
  if (!monitor->silent_b ("InitLexer") && check_debug)
    set_debug (1);

  new_input (main_input_str_, source_global_l);
  
  print_declarations(true);
}

void
My_lily_lexer::set_identifier (String name_str, Identifier* i, bool unique_b)
{
  Identifier *old = lookup_identifier (name_str);
  if  (old)
    {
#if 0
      if (unique_b)
	old->warning(_f ("redeclaration of `\\%s\'", name_str));
#endif
      delete old;
    }
  (*scope_l_arr_.top ())[name_str] = i;
}

My_lily_lexer::~My_lily_lexer()
{
  delete keytable_p_;
  delete toplevel_scope_p_ ;
  delete note_tab_p_;
}

void
My_lily_lexer::print_declarations (bool init_b) const
{
  for (int i=scope_l_arr_.size (); i--; )
    {
      DOUT << "Scope no. " << i << '\n';
      scope_l_arr_[i]->print ();
    }
}

void
My_lily_lexer::LexerError (char const *s)
{
  if (include_stack_.empty())
    {
      *mlog << _f ("error at EOF: %s", s) << endl;
    }
  else
    {
      errorlevel_i_ |= 1;
      Input spot (source_file_l(),here_ch_C());
      spot.error (s);
    }
}

Musical_pitch
My_lily_lexer::lookup_pitch (String s)
{
  return (*note_tab_p_)[s];
}

bool
My_lily_lexer::notename_b (String s) const
{
  return note_tab_p_->elt_b (s);
}

void
My_lily_lexer::add_notename (String s, Musical_pitch p)
{
  (*note_tab_p_)[s] = p;
}

void
My_lily_lexer::clear_notenames()
{
  delete note_tab_p_;
  note_tab_p_ = new Notename_table;
}

char
My_lily_lexer::escaped_char(char c) const
{
  switch(c)
    {
    case 'n':
      return '\n';
    case 't':
      return '\t';

    case '\'':
    case '\"':
    case '\\':
      return c;
    }
  return 0;
}
