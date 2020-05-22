#! /usr/bin/env python
# Time-stamp: <2019-06-07 14:24:49 christophe@pallier.org>

""" WIP: GUI for shuffle """

from tkinter import *
import tkinter.filedialog
from tkinter.filedialog import askopenfilename

def openfile():
    filename = askopenfilename(filetypes=[("Text files", "*.txt")])
    txt = open(filename).read()
    print(txt)
    file.close()


root = Tk()

menu = Menu(root)
root.config(menu=menu)

filemenu = Menu(menu)
menu.add_cascade(label="File", menu=filemenu)
filemenu.add_command(label="Open", command=openfile)
filemenu.add_separator()
filemenu.add_command(label="Exit", command=root.destroy)

helpmenu = Menu(menu)
menu.add_cascade(label='Help', menu=helpmenu)
helpmenu.add_command(label='About', command=None)

root.mainloop()



class StatusBar(Frame):
    def __init__(self, master):
        Frame.__init__(self, master)
        self.label = Label(self, bd=1, relief=SUNKEN, anchor=W)
        self.label.pack(fill=X)

    def set(self, format, *args):
        self.label.config(text=format % args)
        self.label.update_idletasks()

    def clear(self):
        self.label.config(text="m")
        self.label.update_idletasks()

status = StatusBar(root)
status.pack(side=BOTTOM, fill=X)

