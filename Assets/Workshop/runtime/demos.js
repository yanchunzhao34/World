/**
 * 原版演示数据与主页动画函数。steps 是 [时间, 操作]，cam 是 [时间, x, y, zoom]，
 * captions 是 [开始时间, 持续时间, 中文字幕]。game.js 负责播放与恢复临时设置。
 * 原版标识符保留，不在此重新设计演示内容和时间线。
 */
// Original demo commands, camera tracks and captions.
var Yn = class {
        key;
        zh;
        en;
        length;
        scene;
        timeOfDay = 11;
        settings = [];
        steps = [];
        cam = [];
        captions = [];
        constructor(e, t, n, r, i) {
            this.key = e, this.zh = t, this.en = n, this.length = r, this.scene = i
        }
        get title() {
            return jn(`sc.${this.key}`, this.zh, this.en)
        }
        at(e, t) {
            return this.steps.push([e, t]), this
        }
        view(e, t, n, r) {
            return this.cam.push([e, t, n, r]), this
        }
        say(e, t, n, r) {
            return this.captions.push([e, t, n, r]), this
        }
        during(e, t, n, r) {
            for (let i = e; i < t; i += n) this.steps.push([i, r]);
            return this
        }
        time(e) {
            return this.timeOfDay = e, this
        }
    },
    z = (e, t, n, r, i = !1) => a => a.commands.add({
        type: E.Paint,
        material: a.matId(e),
        from: [t, n],
        to: [t, n],
        radius: r,
        spray: 1,
        overwrite: i
    }),
    Xn = (e, t, n = 4) => r => r.commands.add({
        type: E.Ignite,
        material: r.sim.fireId,
        from: [e, t],
        to: [e, t],
        radius: n,
        spray: .5
    }),
    B = (e, t, n, r) => i => i.commands.add({
        type: E.Heat,
        from: [e, t],
        to: [e, t],
        radius: n,
        strength: r
    }),
    Zn = (e, t, n) => r => r.commands.add({
        type: E.Erase,
        from: [e, t],
        to: [e, t],
        radius: n,
        spray: 1
    }),
    Qn = e => e.requestBodify();

function $n() {
    let e = [],
        t = (t, n, r, i, a, o) => {
            let s = new Yn(t, n, r, i, a).time(o);
            return e.push(s), s
        };
    t(`light`, `光的折射与反射`, `Refraction and reflection of light`, 24, `optics`, 10).view(0, 256, 144, 1).say(.3, 2.5, `光的折射与反射`, `Refraction and reflection of light`).view(3, 120, 130, 2.6).say(3, 4.5, `三棱镜：白光分成七色`, `A prism splits white light into colours`).view(8, 215, 205, 2.6).say(8, 4, `水的折射与焦散`, `Water refracts light into caustics`).view(12.5, 145, 215, 2).say(12.5, 4, `镜面反射：阳光被地上的镜子反射回去`, `A floor mirror reflects the sunlight back up`).view(17, 420, 120, 2.6).say(17, 4.5, `玻璃球透镜：灯光汇聚成焦点`, `A glass ball lens focuses the lamplight`).view(23, 256, 144, 1), t(`density`, `密度与浮力`, `Density and buoyancy`, 18.5, `showcase_density`, 11).view(0, 256, 160, 1.6).say(.3, 2.5, `密度与浮力`, `Density and buoyancy`).during(.3, 3.8, .05, z(`water`, 230, 110, 6)).during(.3, 3.8, .05, z(`water`, 282, 110, 6)).during(4, 6.5, .03, z(`oil`, 312, 110, 6)).say(4, 5, `油比水轻，浮在水面上`, `Oil is lighter than water and floats on it`).at(9, z(`toy_wood`, 220, 60, 7)).at(9.3, z(`toy_red`, 290, 50, 5)).at(9.6, Qn).view(9.5, 256, 150, 2.2).say(9.5, 5.5, `木头积木浮在水面上`, `Wooden blocks float on water`).view(17, 256, 144, 1), t(`phase`, `物态变化`, `Changes of state`, 23, `showcase_phase`, 11).view(0, 256, 144, 1).say(.3, 2, `物态变化`, `Changes of state`).view(2, 120, 200, 2.4).say(2, 4.5, `冰受热熔化成水`, `Heated ice melts into water`).during(1, 6.5, .05, B(120, 214, 26, 5)).say(6.5, 5, `继续加热：水沸腾成水蒸气`, `Heated further, the water boils into steam`).during(6.5, 11.5, .05, B(120, 226, 26, 14)).view(12.5, 380, 190, 2).say(12.5, 7, `熔岩遇水凝固成黑曜石，水瞬间汽化`, `Lava meeting water freezes into obsidian; the water flashes to steam`).during(12.5, 15.5, .1, z(`lava`, 380, 120, 4)).view(21.5, 256, 144, 1), t(`flames`, `火焰的颜色`, `Flame colours`, 25.5, `showcase_flames`, 22.5).view(0, 256, 180, 1.2).say(.3, 2, `火焰的颜色`, `Flame colours`).at(2.3, Xn(80, 218)).say(2.3, 3.7, `木头：橙黄色的火焰`, `Wood: an orange-yellow flame`).at(6, Xn(175, 218)).say(6, 4, `硫：蓝紫色的火焰`, `Sulfur: a blue-violet flame`).at(10, B(250, 221, 3, 900)).say(10, 4, `酒精：淡蓝色的火焰`, `Alcohol: a pale blue flame`).at(14, Zn(365, 171, 4)).during(14.5, 15.5, .25, B(365, 168, 3, 1e3)).say(14, 4.5, `甲烷：蓝色的火焰`, `Methane: a blue flame`).at(19, B(437, 222, 3, 1200)).say(19, 4.5, `镁：耀眼的白光`, `Magnesium: a blinding white light`).view(19, 460, 200, 2).view(24, 256, 180, 1.2), t(`reactions`, `化学反应`, `Chemical reactions`, 23, `showcase_reactions`, 14).view(0, 256, 144, 1).say(.3, 1.7, `化学反应`, `Chemical reactions`).view(2, 65, 200, 2.6).say(2, 5, `钠遇水：放出氢气，剧烈燃烧`, `Sodium in water: hydrogen is released and burns violently`).during(2.3, 3.3, .1, z(`sodium`, 65, 170, 3)).view(7.5, 175, 205, 2.6).say(7.5, 6, `酸碱中和：盐酸 + 氢氧化钠 → 食盐水`, `Neutralisation: hydrochloric acid + sodium hydroxide → salt water`).during(8, 10, .05, z(`lye`, 175, 170, 4)).view(14, 300, 190, 2.4).say(14, 6.5, `铝热反应：熔穿铁板`, `Thermite reaction: melting through an iron plate`).at(14.3, B(300, 192, 6, 2500)).view(21.5, 256, 144, 1), t(`glow`, `冷光与荧光`, `Cold light and phosphorescence`, 19.5, `energy`, 23).view(0, 256, 144, 1).say(.3, 2.2, `冷光与荧光`, `Cold light and phosphorescence`).view(2.5, 60, 210, 2.4).say(2.5, 4.5, `鲁米诺遇双氧水：化学发光`, `Luminol meets hydrogen peroxide: chemiluminescence`).view(7.5, 160, 170, 2.2).say(7.5, 4.5, `冷光棒与夜光粉：慢慢变暗`, `Glow sticks and glow powder slowly fade`).view(12.5, 420, 200, 2.2).say(12.5, 4.5, `钨丝：炽热发光`, `A heated tungsten filament glows`).during(10.5, 17.5, .05, B(420, 197, 3, 400)).view(18, 256, 144, 1), t(`rigid`, `积木与刚体`, `Toy blocks and rigid bodies`, 19.5, `showcase_rigid`, 11).view(0, 256, 144, 1).say(.3, 4.5, `积木：受重力下落、翻倒、堆叠`, `Blocks fall, tip over and stack under gravity`).at(1.5, z(`toy_red`, 60, 40, 7)).at(1.5, z(`toy_yellow`, 105, 30, 6)).at(1.5, z(`toy_green`, 140, 45, 6)).at(1.7, Qn).view(5, 420, 200, 2.2).say(5, 4.5, `木头积木浮在水面上`, `Wooden blocks float on water`).view(10, 230, 180, 2.2).say(10, 6, `擦掉木板中间，木板断成两段落下`, `Cut the middle of the plank: it breaks in two and falls`).at(11, Zn(240, 167, 5)).view(18, 256, 144, 1), t(`stained`, `彩色玻璃`, `Stained glass`, 14.5, `showcase_stained`, 10).view(0, 256, 144, 1).say(.3, 4.2, `彩色玻璃：只让自己颜色的光通过`, `Coloured glass lets through only its own colour`).view(4.5, 180, 190, 2.2).say(4.5, 4, `红玻璃下是红光，琥珀玻璃下是琥珀色的光`, `Red light under red glass, amber under amber`).view(9, 400, 190, 2.2).say(9, 3.8, `蓝玻璃下是蓝光`, `Blue light under blue glass`).view(13, 256, 144, 1);
    let n = t(`daycycle`, `从清晨到深夜`, `From dawn to night`, 23, `gallery`, 6).view(0, 256, 144, 1).say(.3, 2.5, `从清晨到深夜`, `From dawn to night`).say(2.8, 3.7, `清晨：阳光斜射，光柱很长`, `Morning: low sun, long shafts of light`).say(6.8, 4, `正午：光柱变短、变亮`, `Noon: shorter, brighter shafts`).say(13, 4, `黄昏：光线变暖`, `Evening: the light turns warm`).say(18, 4.5, `夜晚：只剩灯光`, `Night: only the lamps remain`);
    for (let e = 0; e < 22.5; e += 1 / 30) {
        let t = e;
        n.at(t, e => {
            e.settings.timeOfDay = 6 + 17 * Math.min(Math.max(t / 21.5, 0), 1)
        })
    }
    let r = t(`mirrors`, `镜面长廊`, `Mirror corridor`, 13.5, `showcase_mirrors`, 10).view(0, 256, 195, 1.6).say(.3, 12.5, `光在两面镜子之间来回反射，一次比一次暗`, `Light bounces between two mirrors, dimmer each time`).view(4.5, 150, 195, 2.4).view(8.5, 300, 195, 2.4).view(12.5, 256, 195, 1.6);
    return r.settings = [
        [`MirrorBeamRange`, 260]
    ], t(`cave`, `熔岩洞穴`, `Lava cave`, 14, `cave`, 22).view(0, 256, 144, 1).say(.3, 3, `熔岩洞穴`, `Lava cave`).view(3.5, 130, 232, 2.4).say(3.5, 4.5, `熔岩的红光照亮岩壁`, `The red glow of lava lights the rock`).view(8.5, 380, 120, 2.4).say(8.5, 4.5, `荧光晶体的冷光`, `The cold glow of fluorescent crystals`).view(13, 256, 144, 1), t(`combustion`, `燃烧`, `Combustion`, 27.5, `showcase_combustion`, 20.5).view(0, 256, 180, 1.4).say(.3, 2, `燃烧`, `Combustion`).at(2.3, Xn(160, 236, 6)).at(2.3, Xn(230, 236, 6)).say(2.3, 6, `达到着火点，火沿着木头蔓延`, `At its ignition point, fire spreads along the wood`).view(8.5, 205, 160, 2).say(8.5, 5, `热空气和烟上升`, `Hot air and smoke rise`).at(12.5, Xn(336, 202, 5)).view(13.5, 390, 200, 2).say(13.5, 7.5, `煤燃烧得更慢、更久`, `Coal burns slower and longer`).view(21.5, 195, 215, 2).say(21.5, 4.5, `木头烧尽后只剩灰烬`, `The burnt-out wood leaves only ash`).view(26.5, 256, 180, 1.4), t(`explosion`, `爆炸`, `Explosions`, 16, `showcase_explosion`, 21.5).view(0, 256, 180, 1.4).say(.3, 1.7, `爆炸`, `Explosions`).view(2, 160, 200, 2).say(2, 6, `火药自带氧化剂：猛烈燃烧，引燃木墙`, `Gunpowder carries its own oxidiser: it burns fiercely and sets the barricade alight`).at(2.5, B(145, 234, 6, 2e3)).view(8.5, 385, 200, 2).say(8.5, 5, `氢气遇电火花瞬间爆炸`, `Hydrogen explodes at an electric spark`).at(9.5, z(`arc`, 385, 220, 3, !0)).view(14.5, 256, 180, 1.4), t(`acid`, `酸的腐蚀`, `Acid corrosion`, 17.5, `showcase_acid`, 14).view(0, 256, 180, 1.4).say(.3, 1.7, `酸的腐蚀`, `Acid corrosion`).view(2, 145, 190, 2.4).say(2, 6.5, `盐酸腐蚀铁，放出氢气`, `Hydrochloric acid eats iron, releasing hydrogen`).during(2.3, 4.3, .05, z(`acid`, 145, 170, 4)).view(8.5, 365, 175, 2.4).say(8.5, 7, `盐酸溶解石灰石：冒出二氧化碳`, `Hydrochloric acid dissolves limestone, giving off carbon dioxide`).during(9, 11, .05, z(`acid`, 365, 150, 4)).view(16, 256, 180, 1.4), t(`cold`, `低温`, `Extreme cold`, 19, `showcase_cold`, 13).view(0, 256, 180, 1.4).say(.3, 1.7, `低温`, `Extreme cold`).view(2, 145, 200, 2.4).say(2, 7.5, `液氮（零下196°C）倒进水里：剧烈沸腾，水结成冰`, `Liquid nitrogen (-196 °C) poured into water boils hard and freezes it`).during(2.3, 5.3, .05, z(`liquid_nitrogen`, 145, 175, 4)).view(10, 360, 210, 2.4).say(10, 7, `干冰（零下78°C）直接升华成二氧化碳气体`, `Dry ice (-78 °C) sublimes straight into carbon dioxide gas`).during(9, 17, .05, B(345, 214, 18, 14)).during(9, 17, .05, B(375, 214, 18, 14)).view(17.5, 256, 180, 1.4), t(`volcano`, `火山`, `Volcano`, 23, `volcano`, 19.5).view(0, 256, 144, 1).say(.3, 3.5, `火山喷发`, `A volcanic eruption`).during(.5, 20, .05, z(`lava`, 195, 70, 4)).during(8, 18, .05, z(`lava`, 368, 198, 4)).view(4, 230, 150, 1.8).say(4, 5, `熔岩顺着山坡流下`, `Lava flows down the slope`).view(9.5, 380, 200, 1.8).say(9.5, 8, `熔岩入海：海水汽化，熔岩冷却成岩石`, `Lava meets the sea: the water boils off and the lava cools into rock`).view(21.5, 256, 144, 1), e
}

var er = $n();

// Original title-screen background choreography.
var nr = (e, t, n, r) => i => i.commands.add({
        type: E.Paint,
        material: i.matId(e),
        from: [t, n],
        to: [t, n],
        radius: r,
        spray: 1,
        overwrite: !1
    }),
    rr = (e, t, n = 4) => r => r.commands.add({
        type: E.Ignite,
        material: r.sim.fireId,
        from: [e, t],
        to: [e, t],
        radius: n,
        spray: .5
    }),
    ir = [],
    ar = (e, t, n, r) => {
        for (let i = e; i < t; i += n) ir.push([i, r])
    };
ar(.5, 3.5, .05, nr(`water`, 175, 96, 4)), ar(4, 6.5, .08, nr(`lava`, 245, 96, 3)), ar(7, 8.2, .1, nr(`wood`, 352, 128, 6)), ir.push([10, rr(352, 120, 5)]), ar(13, 13.6, .1, nr(`sodium`, 168, 104, 2)), ir.sort((e, t) => e[0] - t[0]);

function or(e, t, n) {
    for (let [r, i] of ir) r > t && r <= n && i(e)
}
