import tkinter as tk
from tkinter import ttk

class Tooltip:
    def __init__(self, widget, text):
        self.widget = widget
        self.text = text
        self.tipwindow = None
        self.id = None
        self.x = self.y = 0

    def showtip(self):
        if self.tipwindow or not self.text:
            return
        x, y, cx, cy = self.widget.bbox("insert")
        x += self.widget.winfo_rootx() + 25
        y += self.widget.winfo_rooty() + 25
        self.tipwindow = tw = tk.Toplevel(self.widget)
        tw.wm_overrideredirect(True)
        tw.wm_geometry("+%d+%d" % (x, y))
        label = ttk.Label(tw, text=self.text, justify="left",
                          background="#ffffe0", relief="solid", borderwidth=1,
                          font=("tahoma", "8", "normal"))
        label.pack(ipadx=1)

    def hidetip(self):
        tw = self.tipwindow
        self.tipwindow = None
        if tw:
            tw.destroy()

def create_tooltip(widget, text):
    tooltip = Tooltip(widget, text)

    def enter(event):
        tooltip.id = widget.after(1000, tooltip.showtip)

    def leave(event):
        widget.after_cancel(tooltip.id)
        tooltip.hidetip()

    widget.bind('<Enter>', enter)
    widget.bind('<Leave>', leave)

# if __name__ == '__main__':
#     root = tk.Tk()
#     frame = ttk.Frame(root, padding=20)
#     button = ttk.Button(frame, text='Hover me')
#     create_tooltip(button, 'This is a tooltip')
#     button.pack()
#     frame.pack()
#     root.mainloop()