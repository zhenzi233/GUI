def detect_score(img, regions):
    #获取图像数据
    width, height = img.size

    total_pixels = width * height

    region_pixels = 0
    for region in regions:
        region_pixels += len(region)

    return round((1- region_pixels / total_pixels) * 100, 2)
