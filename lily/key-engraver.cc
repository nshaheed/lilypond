/*
  key-engraver.cc -- implement Key_engraver

  source file of the GNU LilyPond music typesetter

  (c) 1997--2006 Han-Wen Nienhuys <hanwen@xs4all.nl>
*/

#include "bar-line.hh"
#include "clef.hh"
#include "context.hh"
#include "engraver.hh"
#include "item.hh"
#include "pitch.hh"
#include "protected-scm.hh"
#include "staff-symbol-referencer.hh"
#include "stream-event.hh"

#include "translator.icc"

/*
  TODO: The representation  of key sigs is all fucked.
*/

/**
   Make the key signature.
*/
class Key_engraver : public Engraver
{
  void create_key (bool);
  void read_event (Stream_event const *r);

  Stream_event *key_event_;
  Item *item_;
  Item *cancellation_;
public:
  TRANSLATOR_DECLARATIONS (Key_engraver);

protected:
  virtual void initialize ();
  virtual void finalize ();
  void stop_translation_timestep ();
  void process_music ();

  DECLARE_TRANSLATOR_LISTENER (key_change);
  DECLARE_ACKNOWLEDGER (clef);
  DECLARE_ACKNOWLEDGER (bar_line);
};

void
Key_engraver::finalize ()
{
}

Key_engraver::Key_engraver ()
{
  key_event_ = 0;
  item_ = 0;
  cancellation_ = 0;
}

void
Key_engraver::create_key (bool is_default)
{
  if (!item_)
    {
      item_ = make_item ("KeySignature",
			 key_event_ ? key_event_->self_scm () : SCM_EOL);

      item_->set_property ("c0-position",
			   get_property ("middleCPosition"));

      SCM last = get_property ("lastKeySignature");
      SCM key = get_property ("keySignature");

      if ((to_boolean (get_property ("printKeyCancellation"))
	   || key == SCM_EOL)
	  && !scm_is_eq (last, key))
	{
	  SCM restore = SCM_EOL;
	  SCM *tail = &restore;
	  for (SCM s = last; scm_is_pair (s); s = scm_cdr (s))
	    {
	      if (scm_assoc (scm_caar (s), key) == SCM_BOOL_F)
		{
		  *tail = scm_acons (scm_caar (s),
				     scm_from_int (0), *tail);
		  tail = SCM_CDRLOC (*tail);
		}
	    }

	  if (scm_is_pair (restore))
	    {
	      cancellation_ = make_item ("KeyCancellation",
					 key_event_
					 ? key_event_->self_scm () : SCM_EOL);
	  
	      cancellation_->set_property ("alteration-alist", restore);
	      cancellation_->set_property ("c0-position",
					   get_property ("middleCPosition"));
	    }
	}
      item_->set_property ("alteration-alist", key);
    }

  if (!is_default)
    {
      SCM visibility = get_property ("explicitKeySignatureVisibility");
      item_->set_property ("break-visibility", visibility);
      if (cancellation_)
	cancellation_->set_property ("break-visibility", visibility);
    }
}

IMPLEMENT_TRANSLATOR_LISTENER (Key_engraver, key_change);
void
Key_engraver::listen_key_change (Stream_event *ev)
{
  /* do this only once, just to be on the safe side.  */
  if (ASSIGN_EVENT_ONCE (key_event_, ev))
    read_event (key_event_);
}

void
Key_engraver::acknowledge_clef (Grob_info info)
{
  (void)info;
  SCM c = get_property ("createKeyOnClefChange");
  if (to_boolean (c))
    create_key (false);
}

void
Key_engraver::acknowledge_bar_line (Grob_info info)
{
  (void)info;
  if (scm_is_pair (get_property ("keySignature")))
    create_key (true);
}

void
Key_engraver::process_music ()
{
  if (key_event_
      || get_property ("lastKeySignature") != get_property ("keySignature"))
    create_key (false);
}

void
Key_engraver::stop_translation_timestep ()
{
  item_ = 0;
  context ()->set_property ("lastKeySignature", get_property ("keySignature"));
  cancellation_ = 0;
  key_event_ = 0;
}

void
Key_engraver::read_event (Stream_event const *r)
{
  SCM p = r->get_property ("pitch-alist");
  if (!scm_is_pair (p))
    return;

  SCM n = scm_list_copy (p);
  SCM accs = SCM_EOL;
  for (SCM s = get_property ("keyAlterationOrder");
       scm_is_pair (s); s = scm_cdr (s))
    {
      if (scm_is_pair (scm_member (scm_car (s), n)))
	{
	  accs = scm_cons (scm_car (s), accs);
	  n = scm_delete_x (scm_car (s), n);
	}
    }

  for (SCM s = n; scm_is_pair (s); s = scm_cdr (s))
    if (scm_to_int (scm_cdar (s)))
      accs = scm_cons (scm_car (s), accs);

  context ()->set_property ("keySignature", accs);
  context ()->set_property ("tonic",
			    r->get_property ("tonic"));
}

void
Key_engraver::initialize ()
{
  context ()->set_property ("keySignature", SCM_EOL);
  context ()->set_property ("lastKeySignature", SCM_EOL);

  Pitch p (0, 0, 0);
  context ()->set_property ("tonic", p.smobbed_copy ());
}

ADD_ACKNOWLEDGER (Key_engraver, clef);
ADD_ACKNOWLEDGER (Key_engraver, bar_line);

ADD_TRANSLATOR (Key_engraver,
		/* doc */ "",
		/* create */ "KeySignature",
		/* accept */ "key-change-event",
		
		/* read */
		"createKeyOnClefChange "
		"explicitKeySignatureVisibility "
		"keyAlterationOrder "
		"keySignature "
		"keySignature "
		"lastKeySignature "
		"printKeyCancellation "
		,
		
		/* write */
		"keySignature "
		"lastKeySignature "
		"tonic ")
