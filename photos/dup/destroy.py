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

    def remove_filename(self, sig, filename):
        print 'deleting image' + filename
        os.remove(filename)

        sig_file = self.DUP_DIR + sig
        sig_file_tmp = self.DUP_DIR + sig + '.tmp'
        print 'removing filename from ' + sig_file
        with open(sig_file, 'r') as f1:
            with open(self.DUP_DIR + sig + '.tmp', 'w') as f2:
                for line in f1:
                    if line.find(filename) == -1:
                        f2.write(line)

        os.rename(sig_file_tmp, sig_file)



class MyImage(Image):
    pr = PictureRepo()
    _exif = DictProperty()

    @property
    def exif(self):
        print 'getting'
        if not self._exif:
            self._exif = self.pr.get_exif(self.source)
        return self._exif


    def on_touch_down(self, touch):
        if self.collide_point(*touch.pos):
            return True
        return super(MyImage, self).on_touch_down(touch)


class Controller(FloatLayout):
    pr = PictureRepo()
    images_box = GridLayout()
    images_compare_box = GridLayout()
    info_box = ObjectProperty(None)
    delete_button = ObjectProperty(None)
    selected_image = DictProperty()
    selected_sig = None

    def __init__(self, **kwargs):
        super(Controller, self).__init__(**kwargs)
        sigs = self.pr.get_signatures_with_dups()
        print len(sigs)
        for x in sigs:
            btn = Button(id=x, text=x[0:10])
            btn.bind(on_press=self.select_sig)
            self.images_box.add_widget(btn)

        self.delete_button.bind(on_press=self.delete_selected)

    def select_sig(self, instance):
        self.update_images(instance.id)
        #print 'select first image' + self.images_compare_box.children[0]
        # self.display_meta(self.images_compare_box.children[1], self.images_compare_box.children[1].exif)
        self.select_image(self.images_compare_box.children[0], '')

    def update_images(self, sig_id):
        self.images_compare_box.clear_widgets()
        self.selected_sig = sig_id
        for x in self.pr.get_filename(sig_id):
            im = MyImage(source=x[7:])
            im.bind(on_touch_down=self.select_image)
            #im.bind(exif=self.display_meta)
            self.images_compare_box.add_widget(im)


    def delete_selected(self, instance):
        self.pr.remove_filename(self.selected_sig, self.selected_image['JWFilename'])
        self.update_images(self.selected_sig)

    def select_image(self, instance, event):
        print(instance)

        if(instance.exif):
            self.display_meta(instance, instance.exif)

    def display_meta(self, instance, exif):
        print 'display_meta'
        self.selected_image = exif
        self.info_box.text = "\n".join([
            exif['JWFiledir'],
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

