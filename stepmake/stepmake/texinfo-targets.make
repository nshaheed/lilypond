
default: $(INFO_FILES)

local-WWW: $(addprefix $(outdir)/,$(TEXI_FILES:.texi=.html))

local-doc: $(OUTTXT_FILES)

