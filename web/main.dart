import 'dart:html';
import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'dart:collection';
import 'dart:web_gl' as webgl;
import 'dart:typed_data';


class Nodo{
  List<Nodo> lista = null;
  int dato;
  int indice;
  double x;
  double y;
  Nodo(int indice,int d){
    this.indice = indice;
    this.dato = d;
  }

  void agregarNodo(Nodo n){
    if(lista == null){
      lista = new List<Nodo>();
      lista.add(n);
    }else{
      lista.insert(1,n);
    }
  }
}

class ArbolN_ario{
  Nodo nodoPrincipal = new Nodo(0,0);
  double auxIndice;
  void insertarNodo(int indiceArbol,int indice,int dato){
    Nodo aux = buscarNodo(nodoPrincipal,indiceArbol);
    //print("aux $aux indice $indice");
    if(aux != null){
      Nodo nuevo = new Nodo(indice,dato);
      aux.agregarNodo(nuevo);
    }
  }
  void listaNodos(Nodo nodo){
    print("Nodo i= ${nodo.indice} d=${nodo.dato} x ${nodo.x} y ${nodo.y}");
    if(nodo.lista != null){
      for(int i =0 ;i<nodo.lista.length;i++){
        Nodo aux = nodo.lista.elementAt(i);
        listaNodos(aux);
      }
    }
  }
  Nodo buscarNodo(Nodo nodo,int index){
    Nodo aux = null;
    //print("nodo ${nodo.indice} ");
    if(nodo.indice == index){
      return nodo;
    }
    if(nodo != null && nodo.lista !=null){
      for(int i=0;i<nodo.lista.length;i++){
        aux = buscarNodo(nodo.lista.elementAt(i),index);
        if(aux!=null){
          break;
        }
      }
    }
    return aux;
  }

  int gradoMaximo(Nodo nodo){
    int max = 0,a;
    Nodo aux = null;
    if(nodo!= null && nodo.lista != null){
      for(int i=0;i<nodo.lista.length;i++){
        aux = nodo.lista.elementAt(i);
        a = gradoMaximo(aux)+1;
        print(" max $max a $a ");
        if(a > max){
          max = a;
        }
      }
    }
    return max;
  }

  void generarGrafo(Nodo nodo,double nivel){
    int max = 0,a;
    Nodo aux = null;
    print("nodo ${nodo.indice} ");
    if(nodo.lista == null){
      print("aqui auxIndice $auxIndice ");
      nodo.x = this.auxIndice;
      this.auxIndice++;
    }
    if(nodo!= null && nodo.lista != null){
      for(int i=0;i<nodo.lista.length;i++){
        aux = nodo.lista.elementAt(i);
        aux.y = nivel;
        generarGrafo(aux,nivel+1);
        print(" max $max a $a nivel $nivel");
      }
      nodo.x = (nodo.lista.elementAt(0).x +
      nodo.lista.elementAt(nodo.lista.length-1).x)/2;
    }
  }
}

class Lesson03 {

  webgl.RenderingContext _gl;
  webgl.Program _shaderProgram;
  int _dimensions = 3;
  int _viewportWidth;
  int _viewportHeight;

  webgl.Buffer _squareVertexPositionBuffer;
  webgl.Buffer _squareVertexColorBuffer;

  webgl.Buffer _lineVertexPositionBuffer;
  webgl.Buffer _lineVertexColorBuffer;

  Matrix4 _pMatrix;
  Matrix4 _mvMatrix;
  Queue<Matrix4> _mvMatrixStack;

  int _aVertexPosition;
  int _aVertexColor;
  webgl.UniformLocation _uPMatrix;
  webgl.UniformLocation _uMVMatrix;

  double _rSquare = 0.0;
  double _lastTime = 0.0;
  ArbolN_ario arbol;

  Lesson03(CanvasElement canvas) {

    _viewportWidth = canvas.width;
    _viewportHeight = canvas.height;
    _gl = canvas.getContext("experimental-webgl");
    _mvMatrixStack = new Queue();
    _initShaders();
    _initBuffers();
    _gl.clearColor(0.0, 0.0, 0.0, 1.0);
    _gl.enable(webgl.RenderingContext.DEPTH_TEST);
  }
  void _mvPushMatrix() {
    _mvMatrixStack.addFirst(_mvMatrix.clone());
  }
  void _mvPopMatrix() {
    if (0 == _mvMatrixStack.length) {
      throw new Exception("Invalid popMatrix!");
    }
    _mvMatrix = _mvMatrixStack.removeFirst();
  }
  void _initShaders() {
    String vsSource = """
    attribute vec3 aVertexPosition;
    attribute vec4 aVertexColor;

    uniform mat4 uMVMatrix;
    uniform mat4 uPMatrix;

    varying vec4 vColor;

    void main(void) {
      gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
      vColor = aVertexColor;
    }
    """;

    String fsSource = """
    precision mediump float;

    varying vec4 vColor;

    void main(void) {
      gl_FragColor = vColor;
    }
    """;

    // vertex shader compilation
    webgl.Shader vs = _gl.createShader(webgl.RenderingContext.VERTEX_SHADER);
    _gl.shaderSource(vs, vsSource);
    _gl.compileShader(vs);

    // fragment shader compilation
    webgl.Shader fs = _gl.createShader(webgl.RenderingContext.FRAGMENT_SHADER);
    _gl.shaderSource(fs, fsSource);
    _gl.compileShader(fs);

    // attach shaders to a WebGL program
    _shaderProgram = _gl.createProgram();
    _gl.attachShader(_shaderProgram, vs);
    _gl.attachShader(_shaderProgram, fs);
    _gl.linkProgram(_shaderProgram);
    _gl.useProgram(_shaderProgram);

    if (!_gl.getShaderParameter(vs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(_gl.getShaderInfoLog(vs));
    }

    if (!_gl.getShaderParameter(fs, webgl.RenderingContext.COMPILE_STATUS)) {
      print(_gl.getShaderInfoLog(fs));
    }

    if (!_gl.getProgramParameter(_shaderProgram, webgl.RenderingContext.LINK_STATUS)) {
      print(_gl.getProgramInfoLog(_shaderProgram));
    }

    _aVertexPosition = _gl.getAttribLocation(_shaderProgram, "aVertexPosition");
    _gl.enableVertexAttribArray(_aVertexPosition);

    _aVertexColor = _gl.getAttribLocation(_shaderProgram, "aVertexColor");
    _gl.enableVertexAttribArray(_aVertexColor);

    _uPMatrix = _gl.getUniformLocation(_shaderProgram, "uPMatrix");
    _uMVMatrix = _gl.getUniformLocation(_shaderProgram, "uMVMatrix");

  }
  void _initBuffers() {
    List<double> colors;
    _squareVertexPositionBuffer = _gl.createBuffer();
    _lineVertexPositionBuffer = _gl.createBuffer();
    _lineVertexColorBuffer = _gl.createBuffer();
    _squareVertexColorBuffer = _gl.createBuffer();
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _squareVertexColorBuffer);
    colors = new List();
    for (int i=0; i < 4; i++) {
      colors.addAll([0.5, 0.5, 1.0, 1.0]);
    }
    _gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(colors), webgl.RenderingContext.STATIC_DRAW);

    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _lineVertexColorBuffer);
    colors = new List();
    for (int i=0; i < 2; i++) {
      colors.addAll([1.0, 0.5, 1.0, 1.0]);
    }
    _gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(colors), webgl.RenderingContext.STATIC_DRAW);

  }
  void _setMatrixUniforms() {
    Float32List tmpList = new Float32List(16);
    _pMatrix.copyIntoArray(tmpList);
    _gl.uniformMatrix4fv(_uPMatrix, false, tmpList);

    _mvMatrix.copyIntoArray(tmpList);
    _gl.uniformMatrix4fv(_uMVMatrix, false, tmpList);
  }
  void crearFigura(double x,double y){
    List<double> vertices;
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _squareVertexPositionBuffer);
    vertices = [
      x+0.3, y+0.3,  0.0,
      x-0.3, y+0.3,  0.0,
      x+0.3, y-0.3,  0.0,
      x-0.3, y-0.3,  0.0
    ];
    _gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), webgl.RenderingContext.STATIC_DRAW);

  }
  void dibujarLinea(double x1, double y1,double x2,double y2){
    List<double> vertices;
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _lineVertexPositionBuffer);
    vertices = [
      x1, y1,  0.0,
      x2, y2,  0.0
    ];
    _gl.bufferDataTyped(webgl.RenderingContext.ARRAY_BUFFER, new Float32List.fromList(vertices), webgl.RenderingContext.STATIC_DRAW);
  }
  void mapearArbol(Nodo nodo){
    double x,y,x1,y1;
    //print("nodo ${nodo.indice} x ${nodo.x} y ${nodo.y}");
    x = nodo.x;
    y = nodo.y;
    if(x!=null && y!=null){
      crearFigura(x,y);
      desplegarNodo();
    }
    if(nodo.lista != null){
      //crearFigura(nodo.x,nodo.y);
      for(int i =0 ;i<nodo.lista.length;i++){
        Nodo aux = nodo.lista.elementAt(i);
        if(x!=null && y!=null){
          x1 = aux.x;
          y1 = aux.y;
          dibujarLinea(x,y,x1,y1);
          desplegarLinea();
        }
        mapearArbol(aux);
      }
    }
  }
  void desplegarNodo(){

    _mvPushMatrix();
    //_mvMatrix.rotate(new Vector3(1.0, 1.0, 0.0), radians(_rSquare));
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _squareVertexPositionBuffer);
    _gl.vertexAttribPointer(_aVertexPosition, _dimensions, webgl.RenderingContext.FLOAT, false, 0, 0);
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _squareVertexColorBuffer);
    _gl.vertexAttribPointer(_aVertexColor, 4, webgl.RenderingContext.FLOAT, false, 0, 0);
    _setMatrixUniforms();
    _gl.drawArrays(webgl.RenderingContext.TRIANGLE_STRIP, 0, 4); // square, start at 0, total 4
    _mvPopMatrix();
  }
  void desplegarLinea(){
    _mvPushMatrix();
    //_mvMatrix.rotate(new Vector3(1.0, 1.0, 0.0), radians(_rSquare));
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _lineVertexPositionBuffer);
    _gl.vertexAttribPointer(_aVertexPosition, _dimensions, webgl.RenderingContext.FLOAT, false, 0, 0);
    _gl.bindBuffer(webgl.RenderingContext.ARRAY_BUFFER, _lineVertexColorBuffer);
    _gl.vertexAttribPointer(_aVertexColor, 4, webgl.RenderingContext.FLOAT, false, 0, 0);
    _setMatrixUniforms();
    _gl.drawArrays(webgl.RenderingContext.LINES, 0, 2); // square, start at 0, total 4
    _mvPopMatrix();

  }
  void render(double time) {
    _gl.viewport(0, 0, _viewportWidth, _viewportHeight);
    _gl.clear(webgl.RenderingContext.COLOR_BUFFER_BIT | webgl.RenderingContext.DEPTH_BUFFER_BIT);
    //_pMatrix = makeOrthographicMatrix(-15,15,-15,15,-15,15);
    _pMatrix = makeOrthographicMatrix(-10,10,-10,10,-10,10);

    int a = arbol.gradoMaximo(arbol.nodoPrincipal);
    //int a = 10;

    _mvMatrix = new Matrix4.identity();
    _mvMatrix.rotate(new Vector3(0.0, 0.0, 1.0), radians(180));
    _mvMatrix.rotate(new Vector3(0.0, 1.0, 0.0), radians(180));
    _mvMatrix.translate(new Vector3(a*-1.0, a*-1.0, 0.0));

    mapearArbol(arbol.nodoPrincipal);
    // rotate
    double animationStep = time - _lastTime;
    _rSquare += (75 * animationStep) / 1000.0;
    _lastTime = time;
    this._renderFrame();
  }
  void start(ArbolN_ario arbol) {
    this._renderFrame();
    this.arbol = arbol;
  }
  void _renderFrame() {
    window.requestAnimationFrame((num time) { this.render(time); });
  }
}

void main() {
  ArbolN_ario arbol = new ArbolN_ario();

  arbol.insertarNodo(0,1,5);
  arbol.insertarNodo(1,2,5);
  arbol.insertarNodo(1,3,5);
  arbol.insertarNodo(1,4,5);
  arbol.insertarNodo(1,13,5);
  arbol.insertarNodo(2,5,5);
  arbol.insertarNodo(2,6,5);
  arbol.insertarNodo(4,7,5);
  arbol.insertarNodo(7,8,5);
  arbol.insertarNodo(7,9,5);
  arbol.insertarNodo(9,19,5);
  arbol.insertarNodo(9,20,5);
  arbol.insertarNodo(10,21,5);
  arbol.insertarNodo(10,22,5);
  /*arbol.insertarNodo(10,23,5);
  arbol.insertarNodo(21,24,5);
  arbol.insertarNodo(21,25,15);
  arbol.insertarNodo(24,26,5);
  arbol.insertarNodo(24,27,5);
  arbol.insertarNodo(26,28,5);
  arbol.insertarNodo(27,29,5);
  arbol.insertarNodo(7,10,5);
  arbol.insertarNodo(8,11,5);
  arbol.insertarNodo(8,12,5);
  arbol.insertarNodo(4,13,5);
  arbol.insertarNodo(4,14,5);
  arbol.insertarNodo(13,15,5);
  arbol.insertarNodo(15,16,5);
  arbol.insertarNodo(16,17,5);
  arbol.insertarNodo(17,18,5);
  arbol.insertarNodo(18,23,5);
  arbol.insertarNodo(23,24,5);
  arbol.insertarNodo(21,25,15);
  arbol.insertarNodo(25,30,5);
  arbol.insertarNodo(30,31,5);
  arbol.insertarNodo(30,34,5);
  arbol.insertarNodo(30,35,5);
  arbol.insertarNodo(31,32,5);
  arbol.insertarNodo(32,33,5);
  arbol.insertarNodo(7,10,5);
  arbol.insertarNodo(8,11,5);
  arbol.insertarNodo(8,12,5);
  arbol.insertarNodo(4,13,5);
  arbol.insertarNodo(4,14,5);
  arbol.insertarNodo(13,15,5);
  arbol.insertarNodo(15,16,5);
  arbol.insertarNodo(13,17,5);
  arbol.insertarNodo(15,18,5);*/


  arbol.auxIndice = 0.0;
  arbol.generarGrafo(arbol.nodoPrincipal,0.0);
  print("---------------------------------------");
  arbol.listaNodos(arbol.nodoPrincipal);
  Lesson03 lesson = new Lesson03(querySelector('#drawHere'));
  lesson.start(arbol);
}