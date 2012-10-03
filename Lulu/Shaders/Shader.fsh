//
//  Shader.fsh
//  Lulu
//
//  Created by Baptiste Bohelay on 2012-10-03.
//  Copyright (c) 2012 Baptiste Bohelay. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
