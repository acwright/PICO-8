PICO-8
======

A repository of my Pico-8 games and demos.

## How to Run PICO-8 Games

### Prerequisites
- Download and install [PICO-8](https://www.lexaloffle.com/pico-8.php) from the official website

### Running Games
1. Open PICO-8
2. Use the `load` command to load a game file:
   ```
   load filename.p8
   ```
3. Run the game with:
   ```
   run
   ```

### Alternative Method
- Drag and drop a `.p8` or `.p8.png` file directly into the PICO-8 window
- Press the play button or use keyboard shortcut to start

### Web Version
- Export games to HTML5 with `export` command
- Open the generated HTML file in a web browser


## Generating itch.io Cover Images

PICO-8's `export`ed `*-label.png` screenshots are 128x128 and treat color 0
(black) as **transparent**, so they render incorrectly when uploaded to itch.io
as a main/cover image. The `*-cover.png` files are generated from them with
ImageMagick:

```sh
for g in bonplanto pong tetris; do
  magick "$g/$g-label.png" -background black -alpha remove -alpha off \
    -filter point -resize 400% \
    -gravity center -background black -extent 640x512 \
    -strip "$g/$g-cover.png"
done
```

- `-background black -alpha remove -alpha off` flattens the transparent pixels
  back to black, restoring the original PICO-8 screen, and drops the alpha
  channel entirely.
- `-filter point -resize 400%` upscales 128x128 to 512x512 with
  nearest-neighbor so the pixel art stays crisp instead of blurring.
- `-extent 640x512` centers that on a black canvas. 640x512 is a 1.25 ratio,
  effectively itch.io's recommended 630x500 cover size, so the image is not
  cropped awkwardly in the game grid.

Substitute the game folder names in the loop to regenerate covers for other
games (`1492`, `dash`, `samples/*`).
