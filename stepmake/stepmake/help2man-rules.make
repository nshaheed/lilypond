# ugh. 
# Man-page:
#	If the #! line does not contain the word "perl", the
#       program named after the #! is executed instead of the Perl
#       interpreter.  This is slightly bizarre, but it helps
# Indeed it is. Perl sucks.
#
$(outdir)/%.1: $(outdir)/%
	$(PERL) $(depth)/buildscripts/$(outdir)/help2man $< > $@ || \
	(echo ""; echo "Apparently the man pages failed to build. This is";\
	echo "no problem, since they don't contain any information anyway.";\
	echo "Please run make again, and be prepared for NO manual pages.")

$(outdir)/%.1: out/%.1
	cp $< $@
