
include $(stepdir)/compile-vars.make

EXTRA_CXXFLAGS= -W -Wall -Wconversion

ALL_CXXFLAGS = $(CXXFLAGS) $(ICFLAGS) $(DEFINES) $(addprefix -I,$(INCLUDES)) $(USER_CFLAGS) $(EXTRA_CFLAGS) $(MODULE_CFLAGS) $($(PACKAGE)_CFLAGS) $($(PACKAGE)_CXXFLAGS) $(USER_CXXFLAGS) $(EXTRA_CXXFLAGS) $(MODULE_CXXFLAGS)

# template files:
TCC_FILES := $(wildcard *.tcc)
HH_FILES := $(wildcard *.hh)
CC_FILES := $(wildcard *.cc)
INL_FILES := $(wildcard *.icc)
YY_FILES := $(wildcard *.yy)
LL_FILES := $(wildcard *.ll)

SOURCE_FILES+= $(CC_FILES) $(YY_FILES) $(INL_FILES) $(TCC_FILES) $(HH_FILES) $(LL_FILES)

ALL_CC_SOURCES += $(HH_FILES) $(INL_FILES) $(CC_FILES) $(YY_FILES) $(LL_FILES) 

O_FILES+=$(addprefix $(outdir)/, $(CC_FILES:.cc=.o) $(LL_FILES:.ll=.o) $(YY_FILES:.yy=.o))

TAGS_SOURCES += $(TCC_FILES) $(INL_FILES) $(CC_FILES) $(YY_FILES) $(LL_FILES)
TAGS_HEADERS += $(HH_FILES) $(INL_FILES)

