# encoding: utf-8
cuDir = File.expand_path(__FILE__).sub(/[^\/]+$/,'')
Dir::chdir(cuDir)
vsn = "3.0"
puts "【打鍵抽出】"

fugo = '-|\/|&|\^|~|_|\"|\+|\.|b|c|\*'	#正規表現用の結構符号
fugotxt = '-/&^~_"+.bc*'	#文字列用の結構符号
kanaroma = 0	#出力字母種選択。0は仮名出力。1はローマ字出力。
h = ""

#Method zima　文字列の指定の位置の符號の括り終りの位置を出力
class String	#zima
def zima(idx)
	n=0
	fugo = '-/&^~_"+.bc*'
	pt = idx
	str = self + ";"
	while 0 <= n
		n +=1 if fugo.include?(str.slice(pt,1)) == true
		n -= 1 if str.slice(pt) == ","
		break if n < 0
		pt += 1
		break if str.slice(pt) == ";"
	end
	return self.slice(idx,pt-idx)
end
end	#zima-end

	#読み込み・分解
	hyoh = Hash::new
	kakikomimoji = Array::new
	zzz = 0
hyo = open("output/jisohyo.txt",'r:utf-8')
hyo.each_line { |n|
	n.chomp!
	next if n.chr == ";"
	next if n.split("\t").fetch(1,"") == ""
	chrt = n.split("\t").fetch(0)
	tkstr = n.split("\t").fetch(1).split("=").fetch(0,"")
	h << chrt
		#zzz = 1 if chrt == "白"
		#next if zzz != 1
		#break if chrt == "皮"	#一口子心日水玄竹艸見金馬〇
		#puts chrt
#字碼抽出
	strokes = Array::new
	koar = Array::new
	x = 0		#判定
	i = 0
	j = 0
	cfu = ""
	#puts chrt
	if fugotxt.include?(tkstr.chr)			#式の多項（式の頭に符號を持つ）ならば
		cfu = tkstr.chr
		koar[j] = tkstr.zima(x+1)	;j += 1			#前頂を初項
		x += tkstr.zima(x+1).length + 2
		koar[j] = tkstr.zima(x)	;j += 1
		koar.each_index{|k|
		ko = koar[k]
		y = 0
		if fugotxt.include?(ko.chr)
			if (k == 0 && '_'.include?(cfu) != true) || (k == koar.length-1 && '_'.include?(cfu) == true)
				strokes[i] = ko.zima(y+1).delete(fugotxt+',')[0]	;i += 1
				y += ko.zima(y+1).length + 2
				/^(.)?(.*(.))$/ =~ko.zima(y).delete(fugotxt+',') 
				(strokes[i] = $3	;i += 1) if $3 != nil
			elsif (k == koar.length-1 && '_'.include?(cfu) != true) || (k == 0 && '_'.include?(cfu) == true)
				l = 0

				
				if fugotxt.include?(ko[y])
					/^(.)(.*(.))?$/ =~ ko.zima(y+1).delete(fugotxt+',')
					(strokes[i] = $1	;i += 1) if $1 != nil
					(strokes[i] = $3	;i += 1) if $3 != nil
					y += ko.zima(y+1).length + 2
					if $3 == nil
						/^((.).*)?(.)$/ =~ ko.zima(y).delete(fugotxt+',')
						(strokes[i] = $2	;i += 1) if $2 != nil
						(strokes[i] = $3	;i += 1) if $3 != nil
					else
						/^((.).*)?(.)$/ =~ ko.zima(y).delete(fugotxt+',')
						(strokes[i] = $3	;i += 1) if $3 != nil
					end
				else
					/^(.)((.)?.*(.))?$/ =~ko.zima(y).delete(fugotxt+',')
					(strokes[i] = $1	;i += 1) if $1 != nil
					(strokes[i] = $3	;i += 1) if $3 != nil
					(strokes[i] = $4	;i += 1) if $4 != nil
				end
			else
				/^(.)(.*(.))?$/ =~ko.zima(y).delete(fugotxt+',')
				(strokes[i] = $1	;i += 1) if $1 != nil
				(strokes[i] = $3	;i += 1) if $3 != nil
			end
		else
				/^(.)(.*(.))?$/ =~ko.zima(y).delete(fugotxt+',')
				(strokes[i] = $1	;i += 1) if $1 != nil
				(strokes[i] = $3	;i += 1) if $3 != nil
		end
		}
	else	#式の單項ならば
		strokes[i] = tkstr.delete(fugotxt+',')
		i+= 1
	end

	strokest = ""
	strokes.each{|chi|
		strokest << chi.tr('ァ-ン','ぁ-ん') if kanaroma == 0
		strokest << chi.tr('アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヰヱヲンヽヮー','AIUEOKKKKKSSSSSTTTTTNNNNNHHHHHMMMMMYYYRRRRRWWWWNZCQ') if kanaroma == 1
	}
	if kakikomimoji.include?("#{strokest}\t#{chrt}\t短縮よみ") != true
		kakikomimoji << "#{strokest}\t#{chrt}\t短縮よみ"
	end
	
	case chrt
when "一" then puts "分析開始。" when "口" then print "子集 了。" when "子" then print "丑集 了。" when "心" then print "寅集 了。" when "日" then print "卯集 了。" when "水" then print "辰集 了。" when "玄" then print "巳集 了。" when "竹" then print "午集 了。" when "艸" then print "未集 了。" when "見" then print "申集 了。" when "金" then print "酉集 了。" when "馬" then print "戌集 了。" when "龦" then print "亥集 了。" when "〇" then puts "補闕部 了。"
end
}

#打鍵重複分別子
class Array
  def ununiq	#重複要素を取り出し
    group_by{|i| i}.reject{|k,v| v.one?}.keys
  end
end

jis = ""
jisfl = open("../zairyo/jis.txt",'r:utf-8')
jisfl.each_char { |ch|
	jis += ch
}
jis << h
hyodaken = Array::new
hyost = Array::new
chofukudaken = Array::new
kakikomimoji.each_with_index { |n,i|
	n.chomp!
	spl = n.split("\t",2)
	hyodaken[i] = spl[0]
	hyost[i] = spl[1]
}
	sss = ""
	chofukudaken = hyodaken.ununiq
	chofukudaken.each_with_index{|m,i|
		hyodaken.map.with_index{ |e,j| e == m ? j: nil}.compact.sort{|a,b|
			jis.index(kakikomimoji[a].split("\t")[1].to_s) <=> jis.index(kakikomimoji[b].split("\t")[1].to_s)
		}.each_with_index{|l,k|
			case k
				when 0 then sss = "ぁ"
				when 1 then sss = "ぃ"
				when 2 then sss = "ぅ"
				when 3 then sss = "ぇ"
				when 4 then sss = "ぉ"
				when 5 then sss = "ゃ"
				when 6 then sss = "ゅ"
				when 7 then sss = "ょ"
			end
		kakikomimoji[l] += "\t-> #{hyodaken[l]}#{sss}"
		kakikomimoji << hyodaken[l] + sss +"\t"+ hyost[l]
		}
	
	}
	puts "分別打鍵了。"

#書き込み
	require "date"
	dt = Date.today
	kakikomi = open('output/ashide.txt', 'wb:UTF-16LE') if kanaroma == 0
	kakikomi = open('output/ashide.txt', 'wb:UTF-16LE') if kanaroma == 1
	kakikomi.write "\uFEFF"
	kakikomi.write("!IME用葦手入力辞書(Japanese IME dictionary of Ashide Input)\n!Made by Haruakira NAKAYAMA in Japan\n!Version #{vsn} in #{dt.year}年#{dt.month}月#{dt.day}日\n")
	kakikomi.write(kakikomimoji.sort{|a, b| a <=> b }.join("\n"))
	kakikomi.close
	puts "出力了。"
