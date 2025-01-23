module _01_getting_started._03_03_shaders;


import libloader;
import bindbc.glfw;
import bindbc.opengl;
import std.stdio;
import source._01_getting_started._01_hello_window;

enum WIDTH = 800;
enum HEIGHT = 600;
enum WINDOW_NAME = "Getting Started - 03 Shaders";

string vertexShaderSource = `#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

out vec3 ourColor;

void main()
{
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor;
}`;


string fragmentShaderSource = `#version 330 core

in vec3 ourColor;
out vec4 FragColor;

void main()
{
    FragColor = vec4(ourColor,1.0);
}`;


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


    uint shaderProgram = glCreateProgram();
    scope (exit)
    {
        glDeleteProgram(shaderProgram);
    }

    {
        uint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        const(char)*[] vertexShaderSourceArray = [vertexShaderSource.ptr];
        glShaderSource(vertexShader, 1, vertexShaderSourceArray.ptr, null);

        //glShaderSource(vertexShader, 1, vertexShaderSource.ptr, null);
        glCompileShader(vertexShader);
        int success;
        char[512] infoLog;
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(vertexShader, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", infoLog.ptr);
            return;
        }
        scope (exit)
        {
            glDeleteShader(vertexShader);
        }

        uint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        const(char)*[] fragmentShaderSourceArray = [fragmentShaderSource.ptr];
        glShaderSource(fragmentShader, 1, fragmentShaderSourceArray.ptr, null);

        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success)
        {
            glGetShaderInfoLog(fragmentShader, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n", infoLog.ptr);
            return;
        }
        scope (exit)
        {
            glDeleteShader(fragmentShader);
        }

        
        glAttachShader(shaderProgram, vertexShader);
        glAttachShader(shaderProgram, fragmentShader);
        glLinkProgram(shaderProgram);
        glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
        if (!success)
        {
            glGetProgramInfoLog(shaderProgram, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", infoLog.ptr);
            return;
        }


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

    while (!glfwWindowShouldClose(windowHandle))
    {
        processInputs(windowHandle);

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);



        glfwPollEvents();
        glfwSwapBuffers(windowHandle);
    }

}
