//
//  BRAStyles.m
//  BRAXlsxReaderWriter
//
//  Created by René BIGOT on 07/10/2014.
//  Copyright (c) 2014 René Bigot. All rights reserved.
//

#import "BRAStyles.h"
#import "BRACellFill.h"
#import "BRACellFormat.h"

@implementation BRAStyles

+ (NSString *)fullRelationshipType {
    return @"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles";
}

- (NSString *)contentType {
    return @"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml";
}

- (NSString *)targetFormat {
    return @"styles.xml";
}

- (void)loadXmlContents {
    [super loadXmlContents];
    
    _attributes = [NSDictionary dictionaryWithOpenXmlString:super.xmlRepresentation];
    
    //Read indexed colors
    NSMutableArray *indexedColors = [BRANativeColor defaultIndexedColors].mutableCopy;
    
    NSArray *colorsArray = [_attributes arrayValueForKeyPath:@"colors.indexedColors.rgbColor"];
    if (colorsArray) {
        NSInteger index = 0;
        for (NSDictionary *indexedColorDict in colorsArray) {
            BRANativeColor *indexedColor = [self colorWithOpenXmlAttributes:indexedColorDict];
            indexedColors[index++] = indexedColor;
        }
    }
    _indexedColors = indexedColors;
    
    
    //Read number formats
    NSMutableDictionary *numberFormats = [[self class] defaultNumberFormats].mutableCopy;
    
    NSArray *numFmtArray = [_attributes arrayValueForKeyPath:@"numFmts.numFmt"];
    if (numFmtArray) {
        for (NSDictionary *formatCodeDict in numFmtArray) {
            numberFormats[formatCodeDict.attributes[@"numFmtId"]] = [[BRANumberFormat alloc] initWithOpenXmlAttributes:formatCodeDict];
        }
    }
    _numberFormats = numberFormats;
}

- (void)loadThemableContent {
    [self loadTextsAttributes];
    [self loadCellBorders];
    [self loadCellFills];
    [self loadCellStyleFormats];
    [self loadCellFormats];
}

- (void)loadCellFills {
    // cellFills must be initialized when all relationships are loaded
    // Theme colors are not already loaded when loadXmlContents is executed
    
    //Read Fills
    NSArray *fillsArray = [_attributes arrayValueForKeyPath:@"fills.fill"];
    NSMutableArray *cellFills = @[].mutableCopy;
    if (fillsArray) {
        for (NSDictionary *fillDict in fillsArray) {
            BRACellFill *fill = [[BRACellFill alloc] initWithOpenXmlAttributes:fillDict inStyles:self];
            [cellFills addObject:fill];
        }
    }
    _cellFills = cellFills;
}

- (void)loadCellStyleFormats {
    // cellStyleFormats must be initialized when all relationships are loaded
    // Theme colors are not already loaded when loadXmlContents is executed
    
    //Read cell style formatting records (cellStyleXfs) /!\ Must be read before cellXfs
    NSMutableArray *cellStyleFormats = @[].mutableCopy;
    NSArray *cellStyleXfArray = [_attributes arrayValueForKeyPath:@"cellStyleXfs.xf"];
    
    if (cellStyleXfArray) {
        for (NSDictionary *formattingRecord in cellStyleXfArray) {
            [cellStyleFormats addObject:[[BRACellFormat alloc] initWithOpenXmlAttributes:formattingRecord inStyles:self]];
        }
    }
    _cellStyleFormats = cellStyleFormats;
}

- (void)loadCellFormats {
    // cellFormats must be initialized when all relationships are loaded
    // Theme colors are not already loaded when loadXmlContents is executed
    
    //Read cell formatting records (cellXfs)
    NSMutableArray *cellFormats = @[].mutableCopy;
    NSArray *cellXfArray = [_attributes arrayValueForKeyPath:@"cellXfs.xf"];
    
    if (cellXfArray) {
        for (NSDictionary *formattingRecord in cellXfArray) {
            [cellFormats addObject:[[BRACellFormat alloc] initWithOpenXmlAttributes:formattingRecord inStyles:self]];
        }
    }
    _cellFormats = cellFormats;
}

- (void)loadTextsAttributes {
    // Texts attributes must be initialized when all relationships are loaded
    // Theme colors are not already loaded when loadXmlContents is executed
    
    //Read Fonts
    NSArray *fontsArray = [_attributes arrayValueForKeyPath:@"fonts.font"];
    NSMutableArray *textsAttributes = [NSMutableArray array];
    NSMutableArray *rawTextsAttributes = [NSMutableArray array];
    if (fontsArray) {
        for (NSDictionary *fontDict in fontsArray) {
            
            NSDictionary *textAttributes = nil;
            BRATextAttributes *rawTextAttributes = nil;
            [self attributedStringAttributesFromOpenXmlAttributes:fontDict textsAttributes:&textAttributes rawTextsAttributes:&rawTextAttributes];
            [textsAttributes addObject:textAttributes];
            [rawTextsAttributes addObject:rawTextAttributes];
        }
    }
    _textsAttributes = textsAttributes;
    _rawTextsAttributes = rawTextsAttributes;
}

- (void)loadCellBorders {
    //Read Borders
    NSArray *bordersArray = [_attributes arrayValueForKeyPath:@"borders.border"];
    NSMutableArray *cellBorders = @[].mutableCopy;
    if (bordersArray) {
        for (NSDictionary *borderDict in bordersArray) {
            BRACellBorder *border = [[BRACellBorder alloc] initWithOpenXmlAttributes:borderDict inStyles:self];
            [cellBorders addObject:border];
        }
    }
    _cellBorders = cellBorders;
}

- (void)attributedStringAttributesFromOpenXmlAttributes:(NSDictionary *)attributes textsAttributes:(NSDictionary **)outputTextsAttributes rawTextsAttributes:(BRATextAttributes **)outputRawTextsAttributes {
    if (!attributes) {
        return;
    }
    
    NSMutableDictionary *attributedStringAttributes = [[NSMutableDictionary alloc] init];
    
    NSDictionary *colorDict = [attributes valueForKeyPath:@"color"];
    
    BRANativeColor *foregroundColor = colorDict == nil ? nil : [self colorWithOpenXmlAttributes:colorDict];
    BRANativeColor *strikeColor = foregroundColor == nil ? [BRANativeColor blackColor] : foregroundColor;
    BOOL hasStrike = attributes[@"strike"] && ![attributes[@"strike"] isEqual:@"0"];
    BOOL hasDoubleStrike = attributes[@"dstrike"] && ![attributes[@"dstrike"] isEqual:@"0"];
    BOOL hasUnderline = attributes[@"u"] && ![attributes[@"u"] isEqual:@"0"];
    if (foregroundColor) {
        attributedStringAttributes[NSForegroundColorAttributeName] = foregroundColor;
    }
    
    if (hasStrike) {
        attributedStringAttributes[NSStrikethroughColorAttributeName] = strikeColor;
        attributedStringAttributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    if (hasDoubleStrike) {
        attributedStringAttributes[NSStrikethroughColorAttributeName] = strikeColor;
        attributedStringAttributes[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleDouble);
    }
    
    if (hasUnderline) {
        attributedStringAttributes[NSUnderlineColorAttributeName] = strikeColor;
        attributedStringAttributes[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
    }
    
    NSString *fontName = [attributes valueForKeyPath:@"name._val"];
    NSInteger fontSize = [[attributes valueForKeyPath:@"sz._val"] integerValue];
    BOOL hasBold = attributes[@"b"] && ![attributes[@"b"] isEqual:@"0"];
    BOOL hasItalic = attributes[@"i"] && ![attributes[@"i"] isEqual:@"0"];
    
    BRANativeFont *font = [BRANativeFont nativeFontWithName:fontName
                                                       size:fontSize
                                                       bold:hasBold
                                                     italic:hasItalic];
    
    if (font) {
        attributedStringAttributes[NSFontAttributeName] = font;
    }
    
    if (outputTextsAttributes) {
        *outputTextsAttributes = attributedStringAttributes;
    }
    
    if (outputRawTextsAttributes) {
        BRATextAttributes *rawTextsAttributes = [BRATextAttributes new];
        rawTextsAttributes.foregroundColor = foregroundColor;
        rawTextsAttributes.strikeColor = strikeColor;
        rawTextsAttributes.hasStrike = hasStrike;
        rawTextsAttributes.hasDoubleStrike = hasDoubleStrike;
        rawTextsAttributes.hasUnderline = hasUnderline;
        rawTextsAttributes.fontName = fontName;
        rawTextsAttributes.fontSize = fontSize;
        rawTextsAttributes.hasBold = hasBold;
        rawTextsAttributes.hasItalic = hasItalic;
        *outputRawTextsAttributes = rawTextsAttributes;
    }
    
    return attributedStringAttributes;
}

- (NSDictionary *)attributedStringAttributesFromOpenXmlAttributes:(NSDictionary *)attributes {
    if (!attributes) {
        return nil;
    }
    
    NSDictionary *attributedStringAttributes = nil;
    [self attributedStringAttributesFromOpenXmlAttributes:attributes textsAttributes:&attributedStringAttributes rawTextsAttributes:nil];
    return attributedStringAttributes;
}

- (BRANativeColor *)colorWithOpenXmlAttributes:(NSDictionary *)attributes {
    if (attributes[@"_indexed"]) {
        
        if ([attributes[@"_indexed"] integerValue] == 81) {
            //81 is used by Excel for comments text colors
            return [BRANativeColor blackColor];
            
        } else {
            return self.indexedColors[[attributes[@"_indexed"] integerValue]];
            
        }
        
    } else if (_theme && attributes[@"_theme"]) {
        NSString *tint = attributes[@"_tint"];
        BRANativeColor *color = [_theme colors][[attributes[@"_theme"] integerValue]];
        if (tint) {
            return [color colorWithTint:tint.floatValue];
        } else {
            return color;
        }
        
    } else if (attributes[@"_rgb"]) {
        NSString *hexString = attributes[@"_rgb"];
        if (hexString.length == 8) {
            hexString = [hexString substringWithRange:NSMakeRange(2, 6)];
        }
        return [BRANativeColor colorWithHexString:hexString];
    }
    
    return nil;
}

- (NSDictionary *)openXmlAttributesWithColor:(BRANativeColor *)color {
    if (color == nil || [color isEqual:[[BRANativeColor blackColor] colorWithAlphaComponent:0]]) {
        return nil;
    }
    
    NSInteger index = [self.indexedColors indexOfObject:color];
    if (index != NSNotFound) {
        return @{
            @"_indexed": [NSString stringWithFormat:@"%ld", (long)index]
        };
    }
    
    index = [_theme.colors indexOfObject:color];
    if (index != NSNotFound) {
        return @{
            @"_theme": [NSString stringWithFormat:@"%ld", (long)index]
        };
    }
    
    return [self rgbColorValueForColor:color];
}

- (NSDictionary *)rgbColorValueForColor:(BRANativeColor *)color {
    CGFloat red = 1., green = 1., blue = 1., alpha = 1.;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    return @{
        @"_rgb": [NSString stringWithFormat:@"%.2X%.2X%.2X%.2X",
                  (int)(alpha * 255),
                  (int)(red * 255),
                  (int)(green * 255),
                  (int)(blue * 255)]
    };
}


#pragma mark - Property setter

- (NSInteger)addStyleByCopyingStyleWithId:(NSInteger)styleId {
    BRACellFormat *cellFormat = _cellFormats[styleId];
    
    NSMutableArray *cellFormats = _cellFormats.mutableCopy;
    [cellFormats addObject:[[BRACellFormat alloc] initWithOpenXmlAttributes:[cellFormat dictionaryRepresentation] inStyles:self]];
    
    _cellFormats = cellFormats;
    
    return cellFormats.count - 1;
}

- (NSString *)addNumberFormat:(BRANumberFormat *)numberFormat {
    NSInteger formatId = 100;
    
    while (_numberFormats[[NSString stringWithFormat:@"%ld", (long)formatId]] != nil) {
        ++formatId;
    }
    
    numberFormat.formatId = [NSString stringWithFormat:@"%ld", (long)formatId];
    
    NSMutableDictionary *numberFormats = _numberFormats.mutableCopy;
    numberFormats[numberFormat.formatId] = numberFormat;
    _numberFormats = numberFormats;
    
    return numberFormat.formatId;
}


#define NUMBER_FORMAT(X) [[BRANumberFormat alloc] initWithOpenXmlAttributes:@{@"_formatCode": X}]
#define ISCN [NSLocale.currentLocale.localeIdentifier containsString:@"CN"]

+ (NSDictionary *)defaultNumberFormats {
    
    static dispatch_once_t pred;
    static NSMutableDictionary *defaultNumberFormats = nil;
    dispatch_once(&pred, ^{
        defaultNumberFormats = @{
            @"0":  NUMBER_FORMAT(@"@"),
            @"1":	NUMBER_FORMAT(@"0"),
            @"2":	NUMBER_FORMAT(@"0.00"),
            @"3":	NUMBER_FORMAT(@"#,##0"),
            @"4":	NUMBER_FORMAT(@"#,##0.00"),
            @"5":	NUMBER_FORMAT(@"_($#,##0_);($#,##0)"),
            @"6":	NUMBER_FORMAT(@"_($#,##0_);[Red]($#,##0)"),
            @"7":	NUMBER_FORMAT(@"_($#,##0.00_);($#,##0.00)"),
            @"8":	NUMBER_FORMAT(@"_($#,##0.00_);[Red]($#,##0.00)"),
            @"9":	NUMBER_FORMAT(@"0%"),
            @"10":	NUMBER_FORMAT(@"0.00%"),
            @"11":	NUMBER_FORMAT(@"0.00E+00"),
            @"12":	NUMBER_FORMAT(@"# ?/?"),
            @"13":	NUMBER_FORMAT(@"# ??/??"),
            @"14":	NUMBER_FORMAT(ISCN ? @"yyyy/m/d" : @"m/d/yy"),
            @"15":	NUMBER_FORMAT(@"d-mmm-yy"),
            @"16":	NUMBER_FORMAT(@"d-mmm"),
            @"17":	NUMBER_FORMAT(@"mmm-yy"),
            @"18":	NUMBER_FORMAT(@"h:mm AM/PM"),
            @"19":	NUMBER_FORMAT(@"h:mm:ss AM/PM"),
            @"20":	NUMBER_FORMAT(@"h:mm"),
            @"21":	NUMBER_FORMAT(@"h:mm:ss"),
            @"22":	NUMBER_FORMAT(@"m/d/yy h:mm"),
            @"37":	NUMBER_FORMAT(@"_(#,##0_);(#,##0)"),
            @"38":	NUMBER_FORMAT(@"_(#,##0_);[Red](#,##0)"),
            @"39":	NUMBER_FORMAT(@"_(#,##0.00_);(#,##0.00)"),
            @"40":	NUMBER_FORMAT(@"_(#,##0.00_);[Red](#,##0.00)"),
            @"41":	NUMBER_FORMAT(@"_(* #,##0_);_(* (#,##0);_(* \"-\"_);_(@_)"),
            @"42":	NUMBER_FORMAT(@"_($* #,##0_);_($* (#,##0);_($* \"-\"_);_(@_)"),
            @"43":	NUMBER_FORMAT(@"_(* #,##0.00_);_(* (#,##0.00);_(* \"-\"??_);_(@_)"),
            @"44":	NUMBER_FORMAT(@"_($* #,##0.00_);_($* (#,##0.00);_($* \"-\"??_);_(@_)"),
            @"45":	NUMBER_FORMAT(@"mm:ss"),
            @"46":	NUMBER_FORMAT(@"[h]:mm:ss"),
            @"47":	NUMBER_FORMAT(@"mm:ss.0"),
            @"48":	NUMBER_FORMAT(@"##0.0E+0"),
            @"49":	NUMBER_FORMAT(@"@"),
            
        }.mutableCopy;
        
        NSDictionary *localeNumberFormats = @{
            @"27": NUMBER_FORMAT(@"yyyy年m月"),
            @"28": NUMBER_FORMAT(@"m月d日"),
            @"29": NUMBER_FORMAT(@"m月d日"),
            @"30": NUMBER_FORMAT(@"m-d-yy"),
            @"31": NUMBER_FORMAT(@"yyyy年m月d日"),
            @"32": NUMBER_FORMAT(@"h时mm分"),
            @"33": NUMBER_FORMAT(@"h时mm分ss秒"),
            @"34": NUMBER_FORMAT(@"上午/下午 h时mm分"),
            @"35": NUMBER_FORMAT(@"上午/下午 h时mm分ss秒"),
            @"36": NUMBER_FORMAT(@"yyyy年m月"),
            @"50": NUMBER_FORMAT(@"yyyy年m月"),
            @"51": NUMBER_FORMAT(@"m月d日"),
            @"52": NUMBER_FORMAT(@"yyyy年m月"),
            @"53": NUMBER_FORMAT(@"m月d日"),
            @"54": NUMBER_FORMAT(@"m月d日"),
            @"55": NUMBER_FORMAT(@"上午/下午 h\"时\"mm\"分\""),
            @"56": NUMBER_FORMAT(@"上午/下午 h\"时\"mm\"分\"ss\"秒\""),
            @"57": NUMBER_FORMAT(@"yyyy年m月"),
            @"58": NUMBER_FORMAT(@"m月d日"),
        };
        [defaultNumberFormats addEntriesFromDictionary:localeNumberFormats];
    });
    return defaultNumberFormats;
}

#pragma mark -

- (NSString *)xmlRepresentation {
    NSMutableDictionary *dictionaryRepresentation = [NSDictionary dictionaryWithOpenXmlString:super.xmlRepresentation].BRA_mutableDeepCopy;
    
    NSString *xmlHeader = @"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n";
    
    //Indexed colors
    if (![_indexedColors isEqual:[BRANativeColor defaultIndexedColors]]) {
        NSMutableArray *indexedColorsArray = @[].mutableCopy;
        
        for (BRANativeColor *color in _indexedColors) {
            [indexedColorsArray addObject:[self rgbColorValueForColor:color]];
        }
        
        [dictionaryRepresentation setValue:indexedColorsArray forKeyPath:@"colors.indexedColors.rgbColor"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)indexedColorsArray.count] forKeyPath:@"colors.indexedColors._count"];
    } else {
        [dictionaryRepresentation[@"colors"] removeObjectForKey:@"indexedColors"];
        if ([dictionaryRepresentation[@"colors"] count] == 0) {
            [dictionaryRepresentation removeObjectForKey:@"colors"];
        }
    }
    
    //Number formats
    NSMutableArray *numFormatsArray = @[].mutableCopy;
    NSArray *formatKeys = [_numberFormats allKeys];
    
    for (NSString *key in formatKeys) {
        //don't add format if it's a defaut format
        if ([[self class] defaultNumberFormats][key] == nil) {
            [numFormatsArray addObject:[_numberFormats[key] dictionaryRepresentation]];
        }
    }
    //    [dictionaryRepresentation setValue:numFormatsArray forKeyPath:@"numFmts.numFmt"];
    dictionaryRepresentation[@"numFmts"] = @{@"numFmt": numFormatsArray}.mutableCopy;
    
    if ([dictionaryRepresentation[@"numFmts"] count] == 0) {
        [dictionaryRepresentation removeObjectForKey:@"numFmts"];
    } else {
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)numFormatsArray.count] forKeyPath:@"numFmts._count"];
    }
    
    //Fonts
    //We won't change old fonts to preserve full properties
    //So we just add the new ones
    NSMutableArray *fontsArray = [dictionaryRepresentation arrayValueForKeyPath:@"fonts.font"].mutableCopy;
    NSInteger oldFontsCount = [fontsArray count];
    
    for (NSInteger i = oldFontsCount; i < _textsAttributes.count; i++) {
        NSDictionary *textAttributes = _textsAttributes[i];
        NSMutableDictionary *fontOpenXmlAttributes = @{}.mutableCopy;
        
        //Font + Size + Bold + Italic
        if (textAttributes[NSFontAttributeName]) {
            
            fontOpenXmlAttributes[@"sz"] = @{@"_val": [NSString stringWithFormat:@"%ld", (long)[textAttributes[NSFontAttributeName] pointSize]]};
            
            NSDictionary *fontAttributes = [textAttributes[NSFontAttributeName] windowsFontProperties];
            
            fontOpenXmlAttributes[@"name"] = @{@"_val": fontAttributes[kBRAFontNameWindows]};
            
            if ([fontAttributes[@"b"] boolValue]) {
                fontOpenXmlAttributes[@"b"] = @{};
            }
            
            if ([fontAttributes[@"i"] boolValue]) {
                fontOpenXmlAttributes[@"i"] = @{};
            }
        }
        
        //Underline
        if ([textAttributes[NSUnderlineColorAttributeName] integerValue] > 0) {
            fontOpenXmlAttributes[@"u"] = @{};
        }
        
        //Color
        if (textAttributes[NSForegroundColorAttributeName]) {
            fontOpenXmlAttributes[@"color"] = [self openXmlAttributesWithColor:textAttributes[NSForegroundColorAttributeName]];
        }
        
        //Strike
        if (textAttributes[NSStrikethroughColorAttributeName]) {
            fontOpenXmlAttributes[@"strike"] = @{};
        }
        
        [fontsArray addObject:fontOpenXmlAttributes];
    }
    
    if (fontsArray.count > oldFontsCount) {
        [dictionaryRepresentation setValue:fontsArray forKeyPath:@"fonts.font"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)fontsArray.count] forKeyPath:@"fonts._count"];
    }
    
    //Fills
    //We won't change old fills to preserve full properties
    //So we just add the new ones
    NSMutableArray *fillsArray = [dictionaryRepresentation arrayValueForKeyPath:@"fills.fill"].mutableCopy;
    NSInteger oldFillsCount = [fillsArray count];
    
    for (NSInteger i = oldFillsCount; i < _cellFills.count; i++) {
        BRACellFill *cellFill = _cellFills[i];
        [fillsArray addObject:[cellFill dictionaryRepresentation]];
    }
    
    if (fillsArray.count > oldFillsCount) {
        [dictionaryRepresentation setValue:fillsArray forKeyPath:@"fills.fill"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)fillsArray.count] forKeyPath:@"fills._count"];
    }
    
    
    //Read cell style formatting records (cellStyleXfs)
    //We won't change old styles formatting records to preserve full properties
    //So we just add the new ones
    NSMutableArray *stylesFormattingRecordsArray = [dictionaryRepresentation arrayValueForKeyPath:@"cellStyleXfs.xf"].mutableCopy;
    NSInteger oldStylesFormattingRecordsCount = [stylesFormattingRecordsArray count];
    
    for (NSInteger i = oldStylesFormattingRecordsCount; i < _cellStyleFormats.count; i++) {
        [stylesFormattingRecordsArray addObject:[_cellStyleFormats[i] dictionaryRepresentation]];
    }
    
    if (stylesFormattingRecordsArray.count > oldStylesFormattingRecordsCount) {
        [dictionaryRepresentation setValue:stylesFormattingRecordsArray forKeyPath:@"cellStyleXfs.xf"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)stylesFormattingRecordsArray.count] forKeyPath:@"cellStyleXfs._count"];
    }
    
    //Read cell style formatting records (cellXfs)
    //We won't change old formatting records to preserve full properties
    //So we just add the new ones
    NSMutableArray *formattingRecordsArray = [dictionaryRepresentation arrayValueForKeyPath:@"cellXfs.xf"].mutableCopy;
    NSInteger oldFormatingRecordsCount = [formattingRecordsArray count];
    
    for (NSInteger i = oldFormatingRecordsCount; i < _cellFormats.count; i++) {
        [formattingRecordsArray addObject:[_cellFormats[i] dictionaryRepresentation]];
    }
    
    if (formattingRecordsArray.count > oldFormatingRecordsCount) {
        [dictionaryRepresentation setValue:formattingRecordsArray forKeyPath:@"cellXfs.xf"];
        [dictionaryRepresentation setValue:[NSString stringWithFormat:@"%ld", (unsigned long)formattingRecordsArray.count] forKeyPath:@"cellXfs._count"];
    }
    
    super.xmlRepresentation = [xmlHeader stringByAppendingString:[dictionaryRepresentation openXmlStringInNodeNamed:@"styleSheet"]];
    
    return super.xmlRepresentation;
}

@end
