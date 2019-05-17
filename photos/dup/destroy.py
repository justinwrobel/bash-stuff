#!/usr/bin/env python
import kivy
kivy.require('1.0.6')

import os
from glob import glob
from random import randint
from os.path import join, isfile, dirname

from kivy.app import App
from kivy.uix.image import Image
from kivy.logger import Logger
from kivy.properties import ObjectProperty, StringProperty
from kivy.uix.button import Button
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.gridlayout import GridLayout
from kivy.uix.label import Label
from kivy.uix.scatter import Scatter
from kivy.properties import DictProperty

from PIL import Image as PilImage
from PIL.ExifTags import TAGS


class PictureRepo():
    DUP_DIR = os.path.expanduser('~/dups/')

    def file_len(self, fname):
        with open(fname) as f:
            for i, l in enumerate(f):
                pass
        return i + 1

    def get_all_signatures(self):
        # https://stackoverflow.com/a/3207973/792789
        return [f for f in os.listdir(self.DUP_DIR) if isfile(join(self.DUP_DIR, f))]

    def get_signatures_with_dups(self):
        return filter(self.filter_signatures_with_dups, self.get_all_signatures())

    def filter_signatures_with_dups(self, fname):
        return self.file_len(self.DUP_DIR + fname) > 1

    def get_filename(self, signature):
        filenames = []

        with open(self.DUP_DIR + signature, "r") as f:
            for line in f:
                filenames.append(line.strip())

        return filenames

    # https://www.blog.pythonlibrary.org/2010/03/28/getting-photo-metadata-exif-using-python/
    def get_exif(self, filename):
        ret = {}
        i = PilImage.open(filename)
        ret['JWResolution'] = "{}x{}".format(i.size[1], i.size[0])
        ret['JWFilename'] = filename
        ret['JWFilebase'] = os.path.basename(filename)
        ret['JWFiledir'] = os.path.dirname(filename)
        info = i._getexif()

        for tag, value in info.items():
            decoded = TAGS.get(tag, tag)
            ret[decoded] = value

        #print ret
        return ret


class MyImage(Image):
    pr = PictureRepo()
    exif = DictProperty()

    def on_touch_down(self, touch):
        if self.collide_point(*touch.pos):
            self.exif = self.pr.get_exif(self.source)
            return True
        return super(MyImage, self).on_touch_down(touch)


class Controller(FloatLayout):
    pr = PictureRepo()
    images_box = ObjectProperty(None)
    images_compare_box = ObjectProperty(None)
    info_box = ObjectProperty(None)
    delete_button = ObjectProperty(None)
    selected_image = DictProperty()

    def __init__(self, **kwargs):
        super(Controller, self).__init__(**kwargs)

        for x in self.pr.get_signatures_with_dups():
            btn = Button(id=x, text=x[0:10])
            btn.bind(on_press=self.update_images)
            self.images_box.add_widget(btn)

        self.delete_button.bind(on_press=self.delete_selected)

    def update_images(self, instance):
        self.images_compare_box.clear_widgets()
        for x in self.pr.get_filename(instance.id):
            im = MyImage(source=x[7:])
            im.bind(on_touch_down=self.select_image)
            im.bind(exif=self.display_meta)
            self.images_compare_box.add_widget(im)

    def delete_selected(self, instance):
        print 'deleting image' + self.selected_image['JWFiledir']
        print 'cleanup repo' + self.selected_image['JWFiledir']
        print 'remove image from view'

    def select_image(self,instance, event):
        if( instance.exif):
            self.display_meta(instance, instance.exif)

    def display_meta(self, instance, exif):
        self.selected_image = exif
        self.info_box.text = "\n".join([
            exif['JWFiledir'][-40:], # TODO show last x chars
            exif['JWFilebase'],
            exif['DateTimeOriginal'],
            exif.get('Make', ''), exif.get('Model', ''),
            exif['JWResolution']])


class PicturesApp(App):

    def build(self):
        return Controller()

    def on_pause(self):
        return True


if __name__ == '__main__':
    PicturesApp().run()

