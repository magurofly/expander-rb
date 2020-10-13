# expander-rb
[ac-library-rb](https://github.com/universato/ac-library-rb/) をコードに埋め込むためのスクリプトです。

# 使い方

1. こちらの [expander.rb](https://raw.githubusercontent.com/surpace/expander-rb/main/expander.rb) をダウンロードしてください。
2. `$ git clone https://github.com/universato/ac-library-rb.git` してください。
3. `require "max_flow"` など、ACLを使用するスクリプトを書きます。
4. `$ ruby expander.rb -I ac-library-rb/lib スクリプトのファイル名` で展開、すかさず全部コピペして提出です！

なお、 `-o 出力ファイル名` オプションをつけると標準出力ではなくファイルに出力できます。
