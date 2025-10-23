import base64
from enum import Enum
from typing import Any, Optional, Callable
from dataclasses import dataclass
from flet.core.constrained_control import ConstrainedControl
from flet.core.control import OptionalNumber
from flet.core.control_event import ControlEvent
from flet.core.event_handler import EventHandler



@dataclass
class ImageWidget:
    type: str = "image"  # DONT CHANGE THIS
    path: str = None
    x: Optional[float] = None
    y: Optional[float] = None
    scale: Optional[float] = None  # New field for scale, default is None


@dataclass
class TextWidget:
    type: str = "text"  # DONT CHANGE THIS
    text: str = None
    x: Optional[float] = None
    y: Optional[float] = None
    color: Optional[str] = None


class SaveEvent(ControlEvent):
    def __init__(self, e: ControlEvent):
        super().__init__(e.target, e.name, e.data, e.control, e.page)
        self.bytes: Optional[bytes] = None
        if e.data:
            try:
                self.bytes = base64.b64decode(e.data)
                print(f"✅ SaveEvent: Successfully decoded {len(self.bytes)} bytes")
            except Exception as ex:
                print(f"❌ SaveEvent: Failed to decode base64 data: {ex}")


class WidgetType(Enum):
    IMAGE = "image"
    TEXT = "text"

class DebugEvent(ControlEvent):
    def __init__(self, e: ControlEvent):
        super().__init__(e.target, e.name, e.data, e.control, e.page)

class EditEvent(ControlEvent):
    def __init__(self, e: ControlEvent):
        super().__init__(e.target, e.name, e.data, e.control, e.page)
        self.widget_type = None
        if e.data:
            try:
                widget_type_str = e.data if isinstance(e.data, str) else str(e.data)
                self.widget_type = WidgetType(widget_type_str) if widget_type_str in WidgetType._value2member_map_ else None
            except (ValueError, AttributeError):
                self.widget_type = None

class FletImageEditor(ConstrainedControl):
    """
    FletImageEditor Control description.
    """

    def __init__(
        self,
        #
        # Image Editor Controls
        #
        layers: Optional[list[dict[str]]] = None,
        on_save: Optional[Callable[[SaveEvent], None]] = None,
        on_debug: Optional[Callable[[DebugEvent], None]] = None,
        on_edit: Optional[Callable[[EditEvent], None]] = None,

        #
        # Control
        #
        opacity: OptionalNumber = None,
        tooltip: Optional[str] = None,
        visible: Optional[bool] = None,
        data: Any = None,
        #
        # ConstrainedControl
        #
        left: OptionalNumber = None,
        top: OptionalNumber = None,
        right: OptionalNumber = None,
        bottom: OptionalNumber = None,
        #
        # FletImageEditor specific
        #
        value: Optional[str] = None,
    ):
        ConstrainedControl.__init__(
            self,
            tooltip=tooltip,
            opacity=opacity,
            visible=visible,
            data=data,
            left=left,
            top=top,
            right=right,
            bottom=bottom,
        )

        self.value = value
        self.layers = layers 
        self.__on_save = EventHandler(lambda e: SaveEvent(e))
        self.__on_debug = EventHandler(lambda e: DebugEvent(e))
        self.__on_edit = EventHandler(lambda e: EditEvent(e))
        self.on_save = on_save
        self.on_debug = on_debug
        self.on_edit = on_edit
        
        self._add_event_handler("on_save", self.__on_save.get_handler())
        self._add_event_handler("debugPrint", self.__on_debug.get_handler())
        self._add_event_handler("onEdit", self.__on_edit.get_handler())

    def _get_control_name(self):
        return "flet_image_editor"

    # value
    @property
    def value(self):
        """
        Value property description.
        """
        return self._get_attr("value")

    @value.setter
    def value(self, value):
        self._set_attr("value", value)
    
    def add_text(self,
                 text: str = None,
                 x: Optional[float] = None,
                 y: Optional[float] = None,
                 color: Optional[str] = None) -> None:
        print(f"🎯 Python: Adding text '{text}' at ({x}, {y}) with color {color}")
        self.invoke_method(
            "addText",
            arguments={
                "text": text,
                "x": str(x) if x is not None else None,
                "y": str(y) if y is not None else None,
                "color": color,
            }
        )
    
    def add_image(self,
                  path: str = None,
                  x: Optional[float] = None,
                  y: Optional[float] = None,
                  scale: Optional[float] = None
                  ) -> None:
        print(f"🎯 Python: Adding image '{path}' at ({x}, {y}) with scale {scale}")
        self.invoke_method(
            "addImage",
            arguments={
                "path": path,
                "x": str(x) if x is not None else None,
                "y": str(y) if y is not None else None,
                "scale": str(scale) if scale is not None else None,
            }
        )
    
    def change_text(self,
                    text: str = None,
                    font_family: Optional[str] = None,
                    x: Optional[float] = None,
                    y: Optional[float] = None,
                    font_size: Optional[float] = None,
                    color: Optional[str] = None) -> None:
        self.invoke_method(
            "changeText",
            arguments={
                "text": text,
                "fontFamily": font_family,
                "x": str(x) if x is not None else None,
                "y": str(y) if y is not None else None,
                "fontSize": str(font_size) if font_size is not None else None,
                "color": color,
            }
        )
    
    # layers
    @property
    def layers(self) -> Optional[list[dict[str, Any]]]:
        return self.__layers

    @layers.setter
    def layers(self, value: Optional[list[dict[str, Any]]]):
        self.__layers = value if value is not None else []
    
    # on_save
    @property
    def on_save(self) -> Optional[Callable[[SaveEvent], None]]:
        return self.__on_save.handler

    @on_save.setter
    def on_save(self, handler: Optional[Callable[[SaveEvent], None]]):
        self.__on_save.handler = handler
    
    # on_debug
    @property
    def on_debug(self) -> Optional[Callable[[DebugEvent], None]]:
        return self.__on_debug.handler

    @on_debug.setter
    def on_debug(self, handler: Optional[Callable[[DebugEvent], None]]):
        self.__on_debug.handler = handler
    
    # on_edit
    @property
    def on_edit(self) -> Optional[Callable[[EditEvent], None]]:
        return self.__on_edit.handler

    @on_edit.setter
    def on_edit(self, handler: Optional[Callable[[EditEvent], None]]):
        self.__on_edit.handler = handler
    
    def save_image_bytes(self, scale: float = None) -> None:
        self.invoke_method(
            "saveImage",
            arguments={
                "scale": str(scale) if scale is not None else None,
            }
        )



