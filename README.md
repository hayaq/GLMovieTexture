GLMovieTexture Unity Plugin
==============

* OpenGL ES2 movie texture for iOS and OSX based on AVFoundation and its Unity plugin.
* http streaming movie is also supported on iOS6 and OSX10.8

Ja
==============
iOS,OSX用ムービーテクスチャUnityプラグイン  
Unityエディタ上でも動作します．  
再生する動画はAssets/StreamingAssetsに配置します

* GLMovieTexture behaviourを使う場合  
コンポーネントインスペクタからテクスチャ画像にMovie.mov.jpgというファイルを指定しておくと
この画像が指定されたマテリアルが自動的にMovie.movのムービーテクスチャとして再生されます．

* GLMovieTextureObjectを使う場合  
スクリプトでGLMovieTextureObjectをインスタンス化し，ムービーテクスチャ化したいTexture2Dインスタンスと
ムービーパスを指定しロードします．
http経由の再生にはこの方法を使います．サンプルプロジェクトExample2を参照．

