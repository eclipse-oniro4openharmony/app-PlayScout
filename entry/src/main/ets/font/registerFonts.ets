//Extract the registry of fonts into a method
import { fonts, Font } from './fonts';
import { font } from '@kit.ArkUI';

export const registerAllFonts = () => {

  Object.keys(fonts).forEach((key)=>{
    const fontDetails: Font = Object(fonts)[key];
    // 注册字体
    font.registerFont({
      familyName: fontDetails.familyName,
      familySrc: fontDetails.familySrc,
    });
  })
};
