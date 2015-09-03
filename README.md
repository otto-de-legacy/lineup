# pXdoppelganger

## what can it do for me?

* pXdoppelganger can compare two images for you.
* pXdoppelganger converts the images into bitstreams and thus analyze every pixcel.
* pXdoppelganger can tell you if those images are equal and what the percentual change is.
* pXdoppelganger can also show you the "difference" image between the two images.

## what are the restrictions?

* pXdoppelganger will only work with PNG files.

## how do I use it?

install the gem:
```
gem install pxdoppelganger
```
and use it:
```
require 'pxdoppelganger'
```

provide paths to images:
```
images = PXDoppelganger::Images.new('~/Downloads/Image1.png', '~/Downloads/Image2.png')
```

see if images are equal:
```
images.equal?
=> true/false
```

get the difference of the two images (in percent):
```
images.difference
=> 1.3849177058385036
```

save the difference-image:
```
images.save_difference_image('~Documents/analysis/diff_image.png')
```

## how do I contribute?

open pull request

## license

MIT: http://opensource.org/licenses/MIT
