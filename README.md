# -
H30/8/14
葦手入力開発用ファイル

　葦手入力の開発に利用されるコード・素材ファイルおよび、それらの使用方法の説明書をまとめてある。
　/zairyo　材料ファイル
・mojihyo.txt　……「文字分析表」　CJK統合漢字表に基づく、入力対象となる文字の分析表
・mojihyo_exa.txt　……「文字分析表・拡張A」　CJK統合漢字拡張Aに基づく文字分析表（開発中H30/8/14）
・exa_sorted.txt　……mojihyo_exa.txtの作業をするための作業用ファイル。後にmojihyo_exa.txtに統合。（開発中H30/8/14）
・henbohyo.txt　……「点画偏旁分析表」　文字分析の要素となる点画や偏旁の分析表
・jis.txt　……JIS漢字表。分別打鍵を附与する際に利用。

　/code　ソースコード
・bunseki.rb　……「文字分析表」「点画偏旁分析表」によって「文字分析表」の分析式を分析して字素による式や字母による式の表（code/output/jisohyo.txt）を生成する。
・kukuri.rb　……code/output/jisohyo.txtによって、打鍵を生成し、IME辞書を出力する（code/output/ashide.txt）。
・ashide.rb　……bunseki.rbとkukuri.rbとを統合させて実行する。

　/manual　仕様書
・nyuroku.html　……入力法の仕様
・shiki.html　……分析表の仕様