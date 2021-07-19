import Foundation
from AppKit import NSObject, NSTextInputContext , NSTextView, NSTextInputContextKeyboardSelectionDidChangeNotification, NSBundle
import multiprocessing
import ctypes
from PyObjCTools import AppHelper
import objc

class Observer(NSObject):

    def initWithValue_(self, txtObj):
        self = objc.super(Observer, self).init()
        self.text_input_context = txtObj
        return self

    def bundle_(self, aNotification):
        self.ime.value = str(self.text_input_context.selectedKeyboardInputSource())

    @staticmethod
    def watch(ime):
        txtObj = NSTextInputContext.alloc().initWithClient_( NSTextView.new() )

        obs = Observer.new().initWithValue_(txtObj)
        obs.ime = ime

        Foundation.NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(obs, 'bundle:', NSTextInputContextKeyboardSelectionDidChangeNotification, None)
        AppHelper.runConsoleEventLoop()

class ImSwitcher():
    mac_ime = 'com.apple.keylayout.ABC'

    def __init__(self) -> None:
        self.text_input_context = NSTextInputContext.alloc().initWithClient_(NSTextView.new())
        self.last_ime = ImSwitcher.mac_ime
        self.is_save_ime = True
        manager = multiprocessing.Manager()
        self.cur_ime = manager.Value(ctypes.c_wchar_p, ImSwitcher.mac_ime)
        multiprocessing.Process(target=Observer.watch, args=(self.cur_ime,)).start()
        try:
            # 隐藏macos dock栏小火箭
            info = NSBundle.mainBundle().infoDictionary()
            info["LSBackgroundOnly"] = "1"
        except ImportError:
            print("隐藏macos dock栏小火箭,需要pip3 install -U PyObjC")

    def swith_insert_mode(self):
        self.switch_input_source(self.last_ime)

    def get_cur_ime(self):
        return self.cur_ime.value

    def toggle_save_last_ime(self):
        self.is_save_ime = not self.is_save_ime
        
    def save_last_ime(self):
        self.last_ime = self.get_cur_ime()

    def switch_normal_mode(self):
        if self.is_save_ime:
            self.save_last_ime()
        self.switch_input_source(self.mac_ime)

    def switch_input_source(self, input_method):
        self.text_input_context.setValue_forKey_(input_method, 'selectedKeyboardInputSource')
