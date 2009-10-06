# default:
#	./makeall.rb

all: charms.html

.PHONY: clean

clean:
	-rm *.png
	-rm *~
	-rm charms.html

%.dot: %.txt dotlib.rb
	./makedot.rb $< $@

%.png: %.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

charms.html: 1_1_Martial_Arts.png 1_2_Survival.png 1_3_Athletics.png 1_4_Sail.png 1_5_Awareness.png 2_1_Archery.png 2_2_Medicine.png 2_3_Performance.png 2_4_Investigation.png 2_5_Ride.png 3_1_Melee.png 3_2_War.png 3_3_Presence.png 3_4_Socialize.png 3_5_Linguistics.png 4_1_Thrown.png 4_2_Dodge.png 4_3_Larceny.png 4_4_Stealth.png 4_5_Occult.png 5_1_Integrity.png 5_2_Resistance.png 5_3_Craft.png 5_4_Lore.png 5_5_Bureaucracy.png ./makehtml.rb
	./makehtml.rb $@
