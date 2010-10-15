# default:
#	./makeall.rb

D=output
MAINFILE=charms.html

W=output_wiki
MAINWIKI=charms_wiki.txt

all: destdir $D/$(MAINFILE) $W/$(MAINWIKI)

.PHONY: clean

clean:
	-rm -rf $D
#	-rm*.png
#	-rm *~
#	-rm charms.html

destdir:
	mkdir -p $D
	mkdir -p $W

$D/%.dot: %.txt dotlib.rb
	./makedot.rb $< $@

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/$(MAINFILE): $D/1_3_Martial_Arts.png $D/1_5_Survival.png $D/1_1_Athletics.png $D/1_4_Sail.png $D/1_2_Awareness.png $D/2_1_Archery.png $D/2_3_Medicine.png $D/2_4_Performance.png $D/2_2_Investigation.png $D/2_5_Ride.png $D/3_2_Melee.png $D/3_5_War.png $D/3_3_Presence.png $D/3_4_Socialize.png $D/3_1_Linguistics.png $D/4_5_Thrown.png $D/4_1_Dodge.png $D/4_2_Larceny.png $D/4_4_Stealth.png $D/4_3_Occult.png $D/5_3_Integrity.png $D/5_5_Resistance.png $D/5_2_Craft.png $D/5_4_Lore.png $D/5_1_Bureaucracy.png $D/6_1_Discordian_Zero_Style.png $D/6_2_Magic_Tree_Style.png $D/6_3_Lotus_Tree_Style.png ./makehtml.rb
	./makehtml.rb . $D $(MAINFILE)
	cp -f intro.html $D/intro.html

#$W/$(MAINWIKI): $D/1_3_Martial_Arts.png $D/1_5_Survival.png $D/1_1_Athletics.png $D/1_4_Sail.png $D/1_2_Awareness.png $D/2_1_Archery.png $D/2_3_Medicine.png $D/2_4_Performance.png $D/2_2_Investigation.png $D/2_5_Ride.png $D/3_2_Melee.png $D/3_5_War.png $D/3_3_Presence.png $D/3_4_Socialize.png $D/3_1_Linguistics.png $D/4_5_Thrown.png $D/4_1_Dodge.png $D/4_2_Larceny.png $D/4_4_Stealth.png $D/4_3_Occult.png $D/5_3_Integrity.png $D/5_5_Resistance.png $D/5_2_Craft.png $D/5_4_Lore.png $D/5_1_Bureaucracy.png $D/6_1_Discordian_Zero_Style.png $D/6_2_Magic_Tree_Style.png $D/6_3_Lotus_Tree_Style.png ./makewiki.rb
$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html
