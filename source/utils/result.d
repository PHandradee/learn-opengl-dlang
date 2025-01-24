module utils.result;


import core.attribute;

// Definição da struct Result com suporte a pattern matching
@mustuse struct Result(T) {
    private T value;
    private string error;
    private bool isOk;

    static Result success(T value) {
        return Result(value, "", true);
    }

    static Result failure(string error) {
        return Result(T.init, error, false);
    }

    T unwrap() const {
        if (!isOk) {
            throw new Exception("Erro não tratado: " ~ error);
        }
        return value;
    }

    R match(R)(R delegate(T) onSuccess, R delegate(string) onError) const {
        if (isOk) {
            return onSuccess(value);
        } else {
            return onError(error);
        }
    }
}
