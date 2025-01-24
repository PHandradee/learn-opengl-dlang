module utils.shader_program;

import std.stdio;
import std.file;
import utils.result;

import bindbc.opengl;

class ShaderProgram {
    this(string vertexShaderPath, string fragmentShaderPath) {
        // Exemplo de leitura de um arquivo com controle de erros usando pattern matching
        string vertexShaderSource = readFile(vertexShaderPath).match(
            (content) {
                return content; // Retorna o conteúdo lido
            },
            (error) {
                writeln("Erro ao ler o arquivo: ", error);
                return ""; // Retorna string vazia em caso de erro
            }
        );

        string fragmentShaderSource = readFile(fragmentShaderPath).match(
            (content) {
                return content; // Retorna o conteúdo lido
            },
            (error) {
                writeln("Erro ao ler o arquivo: ", error);
                return ""; // Retorna string vazia em caso de erro
            }
        );

        uint vertexShader = glCreateShader(GL_VERTEX_SHADER);
        const(char)*[] vertexShaderSourceArray = [vertexShaderSource.ptr];
        glShaderSource(vertexShader, 1, vertexShaderSourceArray.ptr, null);

        glCompileShader(vertexShader);
        int success;
        char[512] infoLog;
        glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &success);
        if (!success) {
            glGetShaderInfoLog(vertexShader, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::VERTEX::COMPILATION_FAILED\n", infoLog.ptr);
            return;
        }
        scope (exit) {
            glDeleteShader(vertexShader);
        }

        uint fragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
        const(char)*[] fragmentShaderSourceArray = [fragmentShaderSource.ptr];
        glShaderSource(fragmentShader, 1, fragmentShaderSourceArray.ptr, null);

        glCompileShader(fragmentShader);
        glGetShaderiv(fragmentShader, GL_COMPILE_STATUS, &success);
        if (!success) {
            glGetShaderInfoLog(fragmentShader, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n", infoLog.ptr);
            return;
        }
        scope (exit) {
            glDeleteShader(fragmentShader);
        }

        m_shaderProgramID = glCreateProgram();

        glAttachShader(m_shaderProgramID, vertexShader);
        glAttachShader(m_shaderProgramID, fragmentShader);
        glLinkProgram(m_shaderProgramID);
        glGetProgramiv(m_shaderProgramID, GL_LINK_STATUS, &success);
        if (!success) {
            glGetProgramInfoLog(m_shaderProgramID, 512, null, infoLog.ptr);
            writeln("ERROR::SHADER::PROGRAM::LINKING_FAILED\n", infoLog.ptr);
            return;
        }
    }

    ~this() {
        glDeleteProgram(m_shaderProgramID);
    }

    // Use/activate the shader
    void use() {
        glUseProgram(m_shaderProgramID);
    }

    // Utility uniform functions
    void setBool(string name, bool value) const {
        glUniform1i(glGetUniformLocation(m_shaderProgramID, name.ptr), cast(int)value);
    }
    void setInt(string name, int value) const {
        glUniform1i(glGetUniformLocation(m_shaderProgramID, name.ptr), value);
    }
    void setFloat(string name, float value) const {
        glUniform1f(glGetUniformLocation(m_shaderProgramID, name.ptr), value);
    }

    int getId() const {
        return m_shaderProgramID;
    }

private:
    int m_shaderProgramID;

    // Método para leitura de arquivo que retorna um Result
    Result!string readFile(string filePath) {
        try {
            // Lê todo o conteúdo do arquivo como texto
            string fileContent = readText(filePath);
            return Result!string.success(fileContent);
        } catch (Exception e) {
            return Result!string.failure(e.msg);
        }
    }
}
