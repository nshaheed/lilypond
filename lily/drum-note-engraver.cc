/*
  drum-note-engraver.cc

  (c) 1997--2006 Han-Wen Nienhuys <hanwen@xs4all.nl>
*/

#include <cctype>
using namespace std;

#include "duration.hh"
#include "engraver.hh"
#include "note-column.hh"
#include "rhythmic-head.hh"
#include "side-position-interface.hh"
#include "script-interface.hh"
#include "stem.hh"
#include "stream-event.hh"
#include "warn.hh"

#include "translator.icc"

class Drum_notes_engraver : public Engraver
{
  vector<Item*> notes_;
  vector<Item*> dots_;
  vector<Item*> scripts_;
  vector<Stream_event*> events_;

public:
  TRANSLATOR_DECLARATIONS (Drum_notes_engraver);

protected:
  void process_music ();
  DECLARE_ACKNOWLEDGER (stem);
  DECLARE_ACKNOWLEDGER (note_column);
  DECLARE_TRANSLATOR_LISTENER (note);
  void stop_translation_timestep ();
};

Drum_notes_engraver::Drum_notes_engraver ()
{
}

IMPLEMENT_TRANSLATOR_LISTENER (Drum_notes_engraver, note);
void
Drum_notes_engraver::listen_note (Stream_event *ev)
{
  events_.push_back (ev);
}

void
Drum_notes_engraver::process_music ()
{
  SCM tab = 0;
  for (vsize i = 0; i < events_.size (); i++)
    {
      if (!tab)
	tab = get_property ("drumStyleTable");

      Stream_event *ev = events_[i];
      Item *note = make_item ("NoteHead", ev->self_scm ());

      Duration dur = *unsmob_duration (ev->get_property ("duration"));

      note->set_property ("duration-log", scm_from_int (dur.duration_log ()));

      if (dur.dot_count ())
	{
	  Item *d = make_item ("Dots", ev->self_scm ());
	  Rhythmic_head::set_dots (note, d);

	  if (dur.dot_count ()
	      != robust_scm2int (d->get_property ("dot-count"), 0))
	    d->set_property ("dot-count", scm_from_int (dur.dot_count ()));

	  d->set_parent (note, Y_AXIS);

	  dots_.push_back (d);
	}

      SCM drum_type = ev->get_property ("drum-type");

      SCM defn = SCM_EOL;

      if (scm_hash_table_p (tab) == SCM_BOOL_T)
	defn = scm_hashq_ref (tab, drum_type, SCM_EOL);

      if (scm_is_pair (defn))
	{
	  SCM pos = scm_caddr (defn);
	  SCM style = scm_car (defn);
	  SCM script = scm_cadr (defn);

	  if (scm_integer_p (pos) == SCM_BOOL_T)
	    note->set_property ("staff-position", pos);
	  if (scm_is_symbol (style))
	    note->set_property ("style", style);

	  if (scm_is_string (script))
	    {
	      Item *p = make_item ("Script", ev->self_scm ());
	      make_script_from_event (p, context (), script,
				      0);

	      p->set_parent (note, Y_AXIS);
	      Side_position_interface::add_support (p, note);
	      scripts_.push_back (p);
	    }
	}

      notes_.push_back (note);
    }
}

void
Drum_notes_engraver::acknowledge_stem (Grob_info inf)
{
  for (vsize i = 0; i < scripts_.size (); i++)
    {
      Grob *e = scripts_[i];

      if (to_dir (e->get_property ("side-relative-direction")))
	e->set_object ("direction-source", inf.grob ()->self_scm ());

      Side_position_interface::add_support (e, inf.grob ());
    }
}

void
Drum_notes_engraver::acknowledge_note_column (Grob_info inf)
{
  for (vsize i = 0; i < scripts_.size (); i++)
    {
      Grob *e = scripts_[i];

      if (!e->get_parent (X_AXIS)
	  && Side_position_interface::get_axis (e) == Y_AXIS)
	e->set_parent (inf.grob (), X_AXIS);
    }
}

void
Drum_notes_engraver::stop_translation_timestep ()
{
  notes_.clear ();
  dots_.clear ();
  scripts_.clear ();

  events_.clear ();
}

ADD_ACKNOWLEDGER (Drum_notes_engraver, stem);
ADD_ACKNOWLEDGER (Drum_notes_engraver, note_column);
ADD_TRANSLATOR (Drum_notes_engraver,
		/* doc */ "Generate noteheads.",
		/* create */ "NoteHead Dots Script",
		/* accept */ "note-event",
		/* read */ "drumStyleTable",
		/* write */ "");

