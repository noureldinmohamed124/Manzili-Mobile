from PIL import Image

def crop_transparent(image_path, output_path):
    try:
        img = Image.open(image_path)
        img = img.convert("RGBA")
        
        # Get bounding box of non-transparent pixels
        bbox = img.getbbox()
        if bbox:
            cropped = img.crop(bbox)
            cropped.save(output_path)
            print(f"Successfully cropped and saved to {output_path}")
        else:
            print("Image is entirely transparent or couldn't find bbox.")
            
    except Exception as e:
        print(f"Error: {e}")

crop_transparent("assets/pngs/logo.png", "assets/pngs/logo_cropped.png")
