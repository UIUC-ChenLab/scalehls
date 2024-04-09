from typing import Callable

class Callable[[MlirOperation], None]:
    def __init__(self, *args, **kwargs) -> None: ...

def emit_hlscpp(module: MlirModule, file_object: object, axi_max_widen_bitwidth: int = ...) -> bool: ...
def get_static_loop_ranges(linalg_op: MlirOperation) -> list: ...
def register_everything(context: object) -> None: ...
def walk_operation(self: MlirOperation, callback: Callable[[MlirOperation], None]) -> None: ...
