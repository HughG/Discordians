D=output
MAINFILE=charms.html

D2=output2
MAINFILE2=charms.html

W=output_wiki
MAINWIKI=charms_wiki.txt

Y=output_yaml
MAINYAML=charms_yaml.txt

all: destdir $D/$(MAINFILE) $W/$(MAINWIKI) yaml

yaml: destdir $Y/$(MAINYAML)

html2: destdir $D2/1_3_Martial_Arts.html $D2/1_5_Survival.html # $D2/$(MAINFILE2)

.PHONY: clean tmpclean

clean:
	-rm -rf $D $D2 $W $Y

tmpclean:
	-rm -rf ./*~ $D/*~ $D2/*~ $W/*~ $Y/*~

destdir:
	mkdir -p $D
	mkdir -p $D2
	mkdir -p $W
	mkdir -p $Y

$D/%.dot: %.txt dotlib.rb
	./makedot.rb $< $@

$D2/%.asc: $Y/%.yml yaml2asciidoc.rb
	./yaml2asciidoc.rb $< $@

$D2/%.html: $D2/%.asc
	asciidoc $< # $@

$D2/%.pdf: $D2/%.asc
	a2x -vv -f pdf --fop --xsl-file=asciidoc/docbook-xsl/fo.xsl $<
	-# asciidoc $< # $@

$Y/%.yml: %.txt makeyaml.rb
	./makeyaml.rb $< $@

$D/%.png: $D/%.dot
	/Applications/Graphviz.app/Contents/MacOS/dot -Tpng $< >$@

$D/$(MAINFILE): intro.html style.css $D/1_3_Martial_Arts.png $D/1_5_Survival.png $D/1_1_Athletics.png $D/1_4_Sail.png $D/1_2_Awareness.png $D/2_1_Archery.png $D/2_3_Medicine.png $D/2_4_Performance.png $D/2_2_Investigation.png $D/2_5_Ride.png $D/3_2_Melee.png $D/3_5_War.png $D/3_3_Presence.png $D/3_4_Socialize.png $D/3_1_Linguistics.png $D/4_5_Thrown.png $D/4_1_Dodge.png $D/4_2_Larceny.png $D/4_4_Stealth.png $D/4_3_Occult.png $D/5_3_Integrity.png $D/5_5_Resistance.png $D/5_2_Craft.png $D/5_4_Lore.png $D/5_1_Bureaucracy.png $D/6_1_Discordian_Zero_Style.png $D/6_2_Magic_Tree_Style.png $D/6_3_Lotus_Tree_Style.png $D/6_4_Paper_Dragon_Style.png ./makehtml.rb
	./makehtml.rb . $D $(MAINFILE)
	cp -f intro.html $D/intro.html
	cp -f style.css $D/style.css

#$W/$(MAINWIKI): $D/1_3_Martial_Arts.png $D/1_5_Survival.png $D/1_1_Athletics.png $D/1_4_Sail.png $D/1_2_Awareness.png $D/2_1_Archery.png $D/2_3_Medicine.png $D/2_4_Performance.png $D/2_2_Investigation.png $D/2_5_Ride.png $D/3_2_Melee.png $D/3_5_War.png $D/3_3_Presence.png $D/3_4_Socialize.png $D/3_1_Linguistics.png $D/4_5_Thrown.png $D/4_1_Dodge.png $D/4_2_Larceny.png $D/4_4_Stealth.png $D/4_3_Occult.png $D/5_3_Integrity.png $D/5_5_Resistance.png $D/5_2_Craft.png $D/5_4_Lore.png $D/5_1_Bureaucracy.png $D/6_1_Discordian_Zero_Style.png $D/6_2_Magic_Tree_Style.png $D/6_3_Lotus_Tree_Style.png $D/6_4_Paper_Dragon_Style.png ./makewiki.rb
$W/$(MAINWIKI): 6_3_Lotus_Tree_Style.txt ./makewiki.rb
	./makewiki.rb . $W $(MAINWIKI)
#	cp -f intro.html $D/intro.html

$Y/$(MAINYAML): $Y/1_3_Martial_Arts.yml $Y/1_5_Survival.yml $Y/1_1_Athletics.yml $Y/1_4_Sail.yml $Y/1_2_Awareness.yml $Y/2_1_Archery.yml $Y/2_3_Medicine.yml $Y/2_4_Performance.yml $Y/2_2_Investigation.yml $Y/2_5_Ride.yml $Y/3_2_Melee.yml $Y/3_5_War.yml $Y/3_3_Presence.yml $Y/3_4_Socialize.yml $Y/3_1_Linguistics.yml $Y/4_5_Thrown.yml $Y/4_1_Dodge.yml $Y/4_2_Larceny.yml $Y/4_4_Stealth.yml $Y/4_3_Occult.yml $Y/5_3_Integrity.yml $Y/5_5_Resistance.yml $Y/5_2_Craft.yml $Y/5_4_Lore.yml $Y/5_1_Bureaucracy.yml $Y/6_1_Discordian_Zero_Style.yml $Y/6_2_Magic_Tree_Style.yml $Y/6_3_Lotus_Tree_Style.yml $Y/6_4_Paper_Dragon_Style.yml
	touch $Y/$(MAINYAML)
