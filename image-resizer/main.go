package main

import (
    "os"
    "io/ioutil"
    "flag"
    "math"
    "github.com/disintegration/imaging"
)

func resize(images []string, per float64) {
    for _, name := range images {
        img, err := imaging.Open(name)
        if err == nil {
            size := img.Bounds().Size()
            width := int(math.Ceil(float64(size.X) * per))
            img := imaging.Resize(img, width, 0, imaging.Lanczos)
            imaging.Save(img, name)
        }
    }
}

func getImages(path string) []string {
    images := make([]string, 0)

    stat, err := os.Stat(path)
    if err != nil {
        return images
    }
    switch md := stat.Mode(); {
    case md.IsRegular():
        return append(images, path)
    case md.IsDir():
        files, err := ioutil.ReadDir(path)
        if (err != nil) {
            return images
        }
        for _, f := range files {
            images = append(images, f.Name())
        }
        return images
    }
    return images
}

func main() {
    var per = flag.Float64("p", 1.0, "Reduction percentage of the image")
    flag.Parse()

    if flag.NArg() == 0 || *per > 1.0 {
        return
    }
    path := flag.Arg(0)
    images := getImages(path)
    resize(images, *per)
}
