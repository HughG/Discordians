# default:
#	./makeall.rb

D=output
MAINFILE=charms.html

all: destdir $D/$(MAINFILE)

.PHONY: clean

clean:
	-rm -rf $D
#	-rm*.png
#	-rm *~
#	-rm charms.html

destdir:
	mkdir -p $D

$D/%.dot: %.txt dotlib.rb
	./makedot.rb $< $@

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/$(MAINFILE): $D/1_1_Martial_Arts.png $D/1_2_Survival.png $D/1_3_Athletics.png $D/1_4_Sail.png $D/1_5_Awareness.png $D/2_1_Archery.png $D/2_2_Medicine.png $D/2_3_Performance.png $D/2_4_Investigation.png $D/2_5_Ride.png $D/3_1_Melee.png $D/3_2_War.png $D/3_3_Presence.png $D/3_4_Socialize.png $D/3_5_Linguistics.png $D/4_1_Thrown.png $D/4_2_Dodge.png $D/4_3_Larceny.png $D/4_4_Stealth.png $D/4_5_Occult.png $D/5_1_Integrity.png $D/5_2_Resistance.png $D/5_3_Craft.png $D/5_4_Lore.png $D/5_5_Bureaucracy.png $D/6_1_Discordian_Zero_Style.png ./makehtml.rb
	./makehtml.rb . $D $(MAINFILE)
	cp -f intro.html $D/intro.html
