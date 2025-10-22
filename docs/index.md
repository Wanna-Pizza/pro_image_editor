# Introduction

FletImageEditor for Flet.

## Examples

```
import flet as ft

from flet_image_editor import FletImageEditor


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(

                ft.Container(height=150, width=300, alignment = ft.alignment.center, bgcolor=ft.Colors.PURPLE_200, content=FletImageEditor(
                    tooltip="My new FletImageEditor Control tooltip",
                    value = "My new FletImageEditor Flet Control", 
                ),),

    )


ft.app(main)
```

## Classes

[FletImageEditor](FletImageEditor.md)


