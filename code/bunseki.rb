# encoding: utf-8
cuDir = File.expand_path(__FILE__).sub(/[^\/]+$/,'')
Dir::chdir(cuDir)

puts "【字素分析】"

jihyoh = Hash::new		#打鍵付与対象文字分析式格納
henbohyoh = Hash::new	#偏旁分析式格納
nodata = Array::new		#不可分析字格納（エラー出力用）
newstrokes = Array::new	#字素式一時格納
irekae = Array::new		#括り改め用
kakikomimoji = Array::new	#字素式出力用
hyoh = Array::new
henbohyor = ""
fugo = '-|\/|&|\^|~|_|\"|\+|\.|b|c|\*'


sw_ns = 1		#新字・入り

#文字表 偏旁表 ハッシュ化
jihyo = open("../zairyo/mojihyo.txt",'r:utf-8')	#文字表ハッシュ化。見出し(":"より前)をキーとして、分析式(タブより前)を値とする。
jihyo.each_line { |i|
	if (i.include?(":") == true) and (i.chr !=";")
		jihyoh[i.chomp.split("\t").fetch(0,"").split(":",2).fetch(0,"")] = i.chomp.split("\t").fetch(0,"").split(":",2).fetch(1,"")
	end
}
jihyo.close;
henbohyo = open("../zairyo/henbohyo.txt",'r:utf-8')	#偏旁表ハッシュ化。見出し(":"より前)をキーとして、分析式(タブより前)を値とする。
henbohyo.each_line{|j|
	if j.split("\t").fetch(0,"").include?(":") == true
		henbohyoh[j.chomp.split("\t").fetch(0,"").split(":",2).fetch(0,"")] = j.chomp.split("\t").fetch(0,"").split(":",2).fetch(1,"")
	end
	henbohyor << j	#
}
henbohyo.close;

chrlistst = "一"	#一
chrlisted = "鿕"	#鿕
chrlist = Array::new
chrlistst.ord.upto(chrlisted.ord){|chrlisti|
	chrlist.push(chrlisti.chr( "UTF-8" ))
}



2.times{|l|
	hyoh = jihyoh.clone if l==0
	hyoh = henbohyoh.clone if l==1
hyoh.each_key{|getchr|
if hyoh.has_key?(getchr) == true
	if hyoh[getchr].scan(/#{fugo}/).size != hyoh[getchr].scan(/,/).size
		nodata.push(getchr)
		puts "error at #{getchr}\t#{hyoh[getchr]}"
		next
	end
	if (hyoh[getchr].count(":") == 0)&&(hyoh[getchr].split("=").fetch(1,"").include?("NS"))
		hyoh[getchr].replace("#{hyoh[getchr].split("=").fetch(0,"")}:#{hyoh[getchr]}")
	end
hyoh[getchr].split(":").each_index{|o|
	siki = hyoh[getchr].split(":").fetch(o,"")
	if siki == ""
		kakikomimoji << "#{getchr}:？"
		nodata.push(getchr) if nodata.include?(getchr) == false
		puts "error :#{getchr}\t#hyoh[getchr]"
		next
	end
	if sw_ns == 1
		siki.split("=").fetch(1,"").include?("NS") ? nsmoji = 1 : nsmoji = 0
	else
		next if (2 <= hyoh[getchr].split(":").length)&&(1 <= o)&&(siki.split("=").fetch(1,"").include?("NS"))
		nsmoji = 0		#nsmoji 0->非日本新字體　1->日本新字體（屬性にNSを含む式）
	end
	#puts "#{getchr}:#{siki}"
	getstroke = siki.split("=").fetch(0,"")
	
	breaking = 0
	a = ""
	aa = ""
	henkango = "？"
	cnt = 0
	n = ""
	if siki =~ /[ァ-ヾ、。]+/
	getstroke = getchr
	n = getchr
	breaking = 1
	end 
	
	while breaking == 0
		getstroke.split(",").reverse_each{|a|	#漢字項を分解して書き換ふ
			next if a =~ /([ァ-ヾ、。]|？)/	#片仮名項ならば送る
			/(#{fugo})*(.+)/ =~ a
			b = $2
			henkango = ""
			if henbohyoh.has_key?(b) == true
				if nsmoji == 1		#新字体処理
					henbohyoh[b].split(":").each{|x|
						if x.split("=").fetch(1,"").include?("NS")
							henkango = x.split("=").fetch(0,"")
						end
					}
				end
				henkango = henbohyoh[b].split(":").fetch(0,"").split("=").fetch(0,"") if henkango == ""
				if henkango == ""
					henkango == "？" 
					nodata.push(b.to_s) if nodata.include?(b) == false
				end
			elsif jihyoh.has_key?(b) == true
				if nsmoji == 1
					jihyoh[b].split(":").each{|x|
						if x.split("=").fetch(1,"").include?("NS")
							henkango = x.split("=").fetch(0,"")
						end
					}
				end
				henkango = jihyoh[b].split(":").fetch(0,"").split("=").fetch(0,"") if henkango == ""
				if henkango == ""
					henkango = "？"
					nodata.push(b.to_s) if nodata.include?(b) == false
				end
			else
				henkango = "？"
				nodata.push(b.to_s) if nodata.include?(b) == false			#
			end
				henkango = "？" if henkango == b

				getstroke.sub!(/((.+,|\A)((#{fugo})*))#{b}(\z|,)/, '\1'+ henkango + '\5')
				t = ""+$3+b+$5
				if henkango =~ /[ァ-ヾ、。]/
					n = t + n
				end
			break
		}
		
		breaking =1 if getstroke.split(",").fetch(0,"？") =~ /([ァ-ヾ、。]|？)/
		cnt += 1
		if 1000 <= cnt
			nodata.push(getchr)
			puts "error :#{getchr}\t#hyoh[getchr]"
			break
		end
	end	#>while breaking == 0
	break if 1000 <= cnt
	
	newstrokes = getstroke.split(',')
	newstrokes = n.split(',')
	

#括り改め
#b,c
	maeidx = -1
	maehosu = -1
	nakaidx = -1
	nakahosu = -1
	ushiroidx = -1
	ushirohosu = -1
	2.times{|i|
		if i == 0
			shiteifu = "c"
			shiteifu2 = "/"
		elsif i == 1
			shiteifu = "~"
			shiteifu2 = "/"
		end
		
		next if /(([^#{Regexp.escape(shiteifu)}])*)((#{Regexp.escape(shiteifu)})+)/ !~ newstrokes.join(",")
		nsidx = $1.count(",")

		if /((#{Regexp.escape(shiteifu)})+)(#{Regexp.escape(shiteifu2)})/ =~ newstrokes[nsidx]
			maeidx = nsidx
			nscnt = $'.count('-/&^~_"+.bc')

			(nsidx+1).step(newstrokes.length,1){|koi|
				if nscnt == 0
					if maehosu == -1
						maehosu = koi - maeidx
						ushiroidx = koi
						nscnt += 1
					elsif ushirohosu == -1
						ushirohosu = koi - ushiroidx
						nakaidx = koi
						nscnt += 1
					elsif nakahosu == -1
						nakahosu = koi - nakaidx
						nscnt += 1
						break
					end
				end
				nscnt -= 1
				nscnt += newstrokes[koi].count('-/&^~_"+.bc')
			}
			newstrokes[nakaidx].insert(0,shiteifu2) if i == 0
			newstrokes[nakaidx-1].insert(0,shiteifu) if i == 1
			newstrokes[maeidx].sub!(/(([^#{Regexp.escape(shiteifu)}])*(#{Regexp.escape(shiteifu)})*)(#{Regexp.escape(shiteifu)})/,'\1')
			if i == 0
			irekae.replace(newstrokes[nakaidx,nakahosu])
			newstrokes[nakaidx,nakahosu] = newstrokes[ushiroidx,ushirohosu]
			newstrokes[ushiroidx,ushirohosu] = irekae
			end
		end
	}  #>1.times{|i|

#~^//--
nsidx = 0
nscnt = 0
tateyokosw = 0
while tateyokosw < 5
	dosu = 0
	shiteifu ="~^" if tateyokosw == 0
	shiteifu ="/" if tateyokosw == 1
	shiteifu ="-" if tateyokosw == 2
	shiteifu ="." if tateyokosw == 3
	shiteifu ="&" if tateyokosw == 4
	if /(#{Regexp.escape(shiteifu).sub(/~/,'~|')}){2,}/ !~ newstrokes.join(",")
		tateyokosw += 1
		next
	end
	
	nsidx = $`.count(",")
	/((#{Regexp.escape(shiteifu).sub(/~/,'~|')}){2,})([^#{Regexp.escape(shiteifu)}].*)\z/ =~ newstrokes[nsidx]
	nscnt = $1.length - 1 + $3.count('-/&^~_"+.bc', "^"+shiteifu.sub(/~/,'~^'))
	while 0 < nscnt			#並列重疊處理
		(nsidx+1).step(newstrokes.length-1,1){|koi|
			nscnt -= 1
			if nscnt == 0
				newstrokes[nsidx].sub!(/((#{Regexp.escape(shiteifu).sub(/~/,'~|')}){2,})([^#{Regexp.escape(shiteifu)}].*)\z/){"#{$1.chop}#{$3}"}
				newstrokes[koi].insert(0,shiteifu.sub(/~\^/,'/'))
				break
			end
			nscnt += newstrokes[koi].count('-/&^~_"+.bc')#, "^"+shiteifu.sub(/~/,'~^'))
		}
	end
end
	getstroke = newstrokes.join(",")
	
	kanacode= ""
	newstrokes.each{|a|
		kanacode += "," if kanacode != ""
		a =~ /((#{fugo})*)(.*)/
		b = $3
		c = $1
		hengo = ""
		if nsmoji ==1 
			henbohyoh[b].split(":").each{|x|
					hengo = x.split("=").fetch(0,"") if x.split("=").fetch(1,"").include?("NS")
			}	
					hengo = henbohyoh[b].split(":").fetch(0,"").split("=").fetch(0,"") if hengo == ""
		else
			hengo = henbohyoh[b].split(":").fetch(0,"").split("=").fetch(0,"") if hengo == ""
		end
			kanacode += c + hengo
	}
	kanacode.gsub!(/[ヮヽーヰヱ]/,"ヰ"=>"イ","ヱ"=>"エ")

	line = "#{getchr}\t#{kanacode}\t#{getstroke}"
	line << "\t#{$1}" if /^#{getchr}:.*\t(#.*?((?=\t)|[^.*\t.*]$))/ =~ henbohyor
	line.insert(0,";") if l == 1	#偏旁ならば行頭に";"を付ける
	kakikomimoji << line if kakikomimoji.include?(line) != true

}	#=> jihyoh[getchr].split(":").each{|siki|
else
	kakikomimoji << "#{getchr}:？"
	nodata.push(getchr) if nodata.include?(getchr) == false
end	#=> if jihyoh.has_key?(getchr) == true

	case getchr 
	when "一" then puts "分析開始。" when "口" then print "子集 了。" when "子" then print "丑集 了。" when "心" then print "寅集 了。" when "日" then print "卯集 了。" when "水" then print "辰集 了。" when "玄" then print "巳集 了。" when "竹" then print "午集 了。" when "艸" then print "未集 了。" when "見" then print "申集 了。" when "金" then print "酉集 了。" when "馬" then print "戌集 了。" when "龦" then print "亥集 了。" when "〇" then puts "補闕部 了。"
	end
}#>chrlist.each{|getchr|
}#>2.times{|n|

#表出力
	if 0 < nodata.compact.length
	kakikomimoji << "\n---error---\n\n"
		nodata.sort.each{|nodatachr|
			kakikomimoji << ";#{nodatachr.to_s}:"
		}
	end
	require "date"
	dt = Date.today
	vsn = "3.1"
	kakikomi = open('output/jisohyo.txt', 'wb:UTF-8')
	kakikomi.write("#葦手入力文字全拆表\n#Made by Haruakira NAKAYAMA in Japan\n#Version #{vsn.to_s} in #{dt.year}年#{dt.month}月#{dt.day}日\n")
	kakikomi.write(kakikomimoji.join("\n"))
	kakikomi.close
	
puts "出力了。"