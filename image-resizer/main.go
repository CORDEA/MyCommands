package main

import (
    "os"
    "log"
    "io/ioutil"
    "flag"
    "math"
    "github.com/disintegration/imaging"
)

var (
    per = flag.Float64("p", 1.0, "Reduction percentage of the image")
)

func resize(images []string, per float64) {
    for _, name := range images {
        img, err := imaging.Open(name)
        if err == nil {
            size := img.Bounds().Size()
            width := int(math.Ceil(float64(size.X) * per))
            img := imaging.Resize(img, width, 0, imaging.Lanczos)
            err = imaging.Save(img, name)
        }
        if err != nil {
            log.Fatalln(err)
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
    }
    return images
}

func main() {
    flag.Parse()

    if flag.NArg() == 0 {
        log.Fatalln("Required argument is missing.")
    }
    path := flag.Arg(0)
    images := getImages(path)
    resize(images, *per)
}
