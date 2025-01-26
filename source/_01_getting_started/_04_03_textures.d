module _01_getting_started._04_03_textures;

import libloader;
import bindbc.glfw;
import bindbc.opengl;
import std.stdio;
import source._01_getting_started._01_hello_window;

import utils.shader_program;

import dlib.image;

enum WIDTH = 800;
enum HEIGHT = 600;
enum WINDOW_NAME = "Getting Started - 04 Textures";

void _main()
{
    // glfw: initialize and configure
    // ------------------------------
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

    version (OSX)
    {
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    }

    // glfw window creation
    // --------------------
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

    // load all OpenGL function pointers
    // ---------------------------------------
    if (!load_opengl())
    {
        writeln("Failed to load OpenGL library");
        return;
    }

    // build and compile our shader zprogram
    // ------------------------------------
    ShaderProgram shaderProgram = new ShaderProgram(
        "shaders/_01_getting_started/_04_03_shaders/vertex_shader.vs",
        "shaders/_01_getting_started/_04_03_shaders/fragment_shader.fs"
    );

    // set up vertex data (and buffer(s)) and configure vertex attributes
    // ------------------------------------------------------------------
    float[] vertices = [
        // positions          // colors           // texture coords
        0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, // top right
        0.5f, -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, // bottom right
        -0.5f, -0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom left
        -0.5f, 0.5f, 0.0f, 1.0f, 1.0f, 0.0f, 0.0f,
        1.0f // top left 
    ];

    int[] indices = [
        0, 1, 3,
        1, 2, 3,
    ];

    uint VBO, VAO, EBO;
    scope (exit)
    {
        glDeleteBuffers(1, &VBO);
        glDeleteBuffers(1, &EBO);
        glDeleteVertexArrays(1, &VAO);
    }

    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.length * float.sizeof, vertices.ptr, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.length * int.sizeof, indices.ptr, GL_STATIC_DRAW);

    // position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*) 0);
    glEnableVertexAttribArray(0);
    // color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*)(3 * float.sizeof));
    glEnableVertexAttribArray(1);
    // texture coord attribute
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * float.sizeof, cast(void*)(6 * float.sizeof));
    glEnableVertexAttribArray(2);

    // texture 1
    // ---------
    uint texture01;
    glGenTextures(1, &texture01);
    glBindTexture(GL_TEXTURE_2D, texture01); // all upcoming GL_TEXTURE_2D operations now have effect on this texture object
    // set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); // set texture wrapping to GL_REPEAT (default wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // load image, create texture and generate mipmaps

    try
    {
        int width, height;
        ubyte[] pixels;
        GLenum format;
        auto img = loadImage("resources/textures/container.jpeg"); // Substitua pelo caminho correto
        width = img.width;
        height = img.height;
        pixels = img.data;
        format = (img.channels == 4) ? GL_RGBA : GL_RGB; 
        writeln("Image loaded successfully: ", width, "x", height);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, format, GL_UNSIGNED_BYTE, pixels
                .ptr);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    catch (Exception e)
    {
        writeln("Failed to load image: ", e.msg);
        return;
    }

        // texture 1
    // ---------
    uint texture02;
    glGenTextures(1, &texture02);
    glBindTexture(GL_TEXTURE_2D, texture02); // all upcoming GL_TEXTURE_2D operations now have effect on this texture object
    // set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT); // set texture wrapping to GL_REPEAT (default wrapping method)
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // set texture filtering parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    // load image, create texture and generate mipmaps
    try
    {
        int width, height;
        ubyte[] pixels;
        GLenum format;
        auto img = rotateImage(loadImage("resources/textures/awesome-face.png"),180); 
        
        width = img.width;
        height = img.height;
        pixels = img.data;
        format = (img.channels == 4) ? GL_RGBA : GL_RGB; 
        writeln("Image loaded successfully: ", width, "x", height);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, format, GL_UNSIGNED_BYTE, pixels
                .ptr);
        glGenerateMipmap(GL_TEXTURE_2D);
    }
    catch (Exception e)
    {
        writeln("Failed to load image: ", e.msg);
        return;
    }

    // tell opengl for each sampler to which texture unit it belongs to (only has to be done once)
    // -------------------------------------------------------------------------------------------
    shaderProgram.use(); // don't forget to activate/use the shader before setting uniforms!
    // either set it manually like so:
    glUniform1i(glGetUniformLocation(shaderProgram.getId(), "texture1"), 0);
    // or set it via the texture class
    shaderProgram.setInt("texture2", 1);


    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glBindVertexArray(0);

    glViewport(0, 0, WIDTH, HEIGHT);

    glfwSetFramebufferSizeCallback(windowHandle, &framebufferSizeCallback);

    glPolygonMode(GL_FRONT_AND_BACK, GL_FLAT);

    // render loop
    // -----------
    while (!glfwWindowShouldClose(windowHandle))
    {
        // input
        // -----
        processInputs(windowHandle);

        // render
        // ------
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // bind textures on corresponding texture units
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, texture01);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, texture02);

        // render container
        shaderProgram.use();
        glBindVertexArray(VAO);
        //glDrawArrays(GL_TRIANGLES, 0, 3);
        glDrawElements(GL_TRIANGLES, cast(int) indices.length, GL_UNSIGNED_INT, cast(void*) 0);

        glfwPollEvents();
        glfwSwapBuffers(windowHandle);
    }

}
