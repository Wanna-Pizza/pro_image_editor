import flet as ft

from flet_image_editor import FletImageEditor


def main(page: ft.Page):
    page.vertical_alignment = ft.MainAxisAlignment.CENTER
    page.horizontal_alignment = ft.CrossAxisAlignment.CENTER

    page.add(

                ft.Container(height=500, width=500, alignment = ft.alignment.center, bgcolor=ft.Colors.PURPLE_200, content=FletImageEditor(
                    tooltip="My new FletImage123424Editor Control tooltip",
                    value = "My new BRUHHditor Flet Control", 
                ),),

    )


ft.app(main)
