#include "scalehls/InitAllDialects.h"
#include "mlir/Tools/mlir-lsp-server/MlirLspServerMain.h"

using namespace mlir;

static int asMainReturnCode(LogicalResult r)
{
    return r.succeeded() ? EXIT_SUCCESS : EXIT_FAILURE;
}

int main(int argc, char* argv[])
{
    DialectRegistry registry;
    scalehls::registerAllDialects(registry);

    return asMainReturnCode(MlirLspServerMain(argc, argv, registry));
}
