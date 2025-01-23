module _01_getting_started._03_02_shaders ;


import libloader;
import bindbc.glfw;
import bindbc.opengl;
import std.stdio;
import std.math: sin;
import source._01_getting_started._01_hello_window;

enum WIDTH = 800;
enum HEIGHT = 600;
enum WINDOW_NAME = "Getting Started - 03 Shaders";

string vertexShaderSource = `#version 330 core
layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}`;


string fragmentShaderSource = `#version 330 core

out vec4 FragColor;

uniform vec4 ourColor;

void main()
{
    FragColor = ourColor;
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
        -0.5f, -0.5f, 0.0f,
        0.5f, -0.5f, 0.0f,
        0.0f, 0.5f, 0.0f
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
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * float.sizeof, cast(void*)0);
    glEnableVertexAttribArray(0);
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

        // update the uniform color
        double timeValue = glfwGetTime();
        float greenValue = sin(timeValue) / 2.0f + 0.5f;
        int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");
        if (vertexColorLocation == -1) 
        {
            writefln("Failed to Retrieve the Uniform location called ourColor");
            glfwSetWindowShouldClose(windowHandle, 1);
        }
        glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);

        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);



        glfwPollEvents();
        glfwSwapBuffers(windowHandle);
    }

}
