module _01_getting_started._03_05_shaders;


import libloader;
import bindbc.glfw;
import bindbc.opengl;
import std.stdio;
import source._01_getting_started._01_hello_window;

import utils.shader_program;

enum WIDTH = 800;
enum HEIGHT = 600;
enum WINDOW_NAME = "Getting Started - 03 Shaders";


void _main()
{
    if (load_glfw() == false)
    {
        writeln("Failed to load GLFW Library");
        return;
    }

    if (glfwInit() == GL_FALSE)
    {
        writeln("Failed to initialize GLFW");
        return;
    }
    scope (exit)
    {
        glfwTerminate();
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    version(OSX)
    {
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    }


    GLFWwindow* windowHandle = glfwCreateWindow(WIDTH, HEIGHT, WINDOW_NAME, null, null);
    if (windowHandle is null)
    {
        writeln("Failed to create GLFW window");
        return;
    }
    scope (exit)
    {
        glfwDestroyWindow(windowHandle);
        windowHandle = null;
    }

    glfwMakeContextCurrent(windowHandle);

    if (!load_opengl())
    {
        writeln("Failed to load OpenGL library");
        return;
    }


    float[] vertices = [
    // positions         // colors
     0.5f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // bottom right
    -0.5f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // bottom left
     0.0f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // top 
    ];

    uint VBO, VAO;
    scope (exit)
    {
        glDeleteBuffers(1, &VBO);
        glDeleteVertexArrays(1, &VAO);
    }

    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);
    
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * float.sizeof, cast(void*)0);
    glEnableVertexAttribArray(0);
    
    glVertexAttribPointer(1,3, GL_FLOAT, GL_FALSE ,6 * float.sizeof, cast(void*)(3 *float.sizeof));
    glEnableVertexAttribArray(1);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);


    glViewport(0, 0, WIDTH, HEIGHT);

    glfwSetFramebufferSizeCallback(windowHandle, &framebufferSizeCallback);

    
    ShaderProgram ourShader = new ShaderProgram(
        "shaders/_01_getting_started/_03_05_shaders/vertex_shader.vs",
        "shaders/_01_getting_started/_03_05_shaders/fragment_shader.fs"
    );
    
    while (!glfwWindowShouldClose(windowHandle))
    {
        processInputs(windowHandle);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        ourShader.use();
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);



        glfwPollEvents();
        glfwSwapBuffers(windowHandle);
    }

}
