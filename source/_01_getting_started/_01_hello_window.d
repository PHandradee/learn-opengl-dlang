module source._01_getting_started._01_hello_window;

//import glad.gl.all;
import bindbc.opengl;
import bindbc.glfw;
import std.stdio;
import libloader;

void _main() {
    // Tenta carregar o GLFW
    auto ret = loadGLFW();
    if (ret != glfwSupport) {
        writefln(
            ret == GLFWSupport.noLibrary ? "No GLFW library found!" :
            ret == GLFWSupport.badLibrary ? "A newer version of GLFW is needed. Please, upgrade!" :
            "Unknown error! Could not load OpenGL library!"
        );
        return;
    }
    writefln("GLFW successfully loaded, version: %s", ret);

    // Inicializa o GLFW
    if (glfwInit() == GL_FALSE) {
        writefln("Failed to initialize GLFW");
        return;
    }

    // Escopo de saída para destruir a janela e finalizar o GLFW
    scope(exit) {
        glfwTerminate();
    }

    // Configura a versão do contexto OpenGL
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    
    // Cria uma janela GLFW
    GLFWwindow* window = glfwCreateWindow(800, 600, "LearnOpenGL", null, null);
    if (window == null) {
        writefln("Failed to create GLFW window");
        return;
    }
    scope(exit) {   glfwDestroyWindow(window); window = null; }

    // Torna a janela o contexto atual
    glfwMakeContextCurrent(window);

    // Inicializa o GLAD com o carregador do GLFW
    //if (!gladLoadGLLoader(&loadProc)) {
    //    writefln("Failed to initialize GLAD");
    //    return;
    //}
    //writeln("GLAD successfully loaded!");


    if(!load_opengl()) {        
        writeln("Failed to load OpenGL library!");
        return;
    }
    

    // Inicializa a viewport com o tamanho da janela
    glViewport(0, 0, 800, 600);
    
    //Seta um funçãod e callback que será chamada quando o Framebuffer mudar o seu tamanho
    glfwSetFramebufferSizeCallback(window, &framebufferSizeCallback);

    // Loop principal de renderização
    while (!glfwWindowShouldClose(window)) {


        //Processa input
        processInputs(window);

        // render
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // Processa eventos 
        glfwPollEvents();
        // Troca os buffers
        glfwSwapBuffers(window);
    }
}

// Função de carregamento
void* loadProc(const char* name) {
    // Usamos a função do GLFW para carregar os ponteiros de função do OpenGL
    return glfwGetProcAddress(name);
}

extern(C) void framebufferSizeCallback(GLFWwindow* window, int width, int height) nothrow
{
    glViewport(0, 0, width, height);
}
 
void processInputs(GLFWwindow* window) 
{
    if (glfwGetKey(window, GLFW_KEY_ESC) == GLFW_PRESS) 
    {
        glfwSetWindowShouldClose(window, GLFW_TRUE);
    }
}
