import SwiftUI

struct ExtraPrepView: View {
    @Environment(\.openURL) private var openURL
    var slug: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch slug {
            case "animation":
                animation
            case "digital-design":
                digital
            case "makeup-design":
                makeup
            case "game-design":
                games
            case "programming-for-games":
                programming
            default:
                Text("Program Preparation")
                    .font(.system(.largeTitle, design: .serif))
            }
        }
    }

    private var animation: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("School of Animation & VFX")
                .font(.system(.largeTitle, design: .serif))
            Text("Orientation guide for 3D Animation & VFX, Classical Animation, and Animation Concept Art")
                .foregroundStyle(Color.stoneLabel)
            Text("Welcome to Vancouver Film School!")
                .font(.title3)
            Text("We're so delighted you're joining our community this year.")
                .foregroundStyle(Color.stoneLabel)
            Text("6 terms. 8 weeks per term. Campus access 24/7.")
            heading("3D Animation & Visual Effects")
            lines(["Autodesk Maya — Free student license", "Autodesk Flow — Free", "Unreal Engine 5 — Free", "Adobe Premiere — Subscription required", "Adobe Photoshop — Subscription required", "Substance Painter — Student license available", "Substance Designer — Student license available", "Nuke — Student license available", "Houdini — Student license available", "ZBrush — Student license available"])
            heading("Animation Concept Art")
            lines(["Adobe Photoshop — Subscription required", "Adobe Premiere — Subscription required", "Toon Boom Harmony — Student license available", "Autodesk Maya — Free student license", "ZBrush — Student license available"])
            heading("Classical Animation")
            lines(["Adobe Premiere — Subscription required", "Adobe Photoshop — Subscription required", "Toon Boom Harmony — Free on request", "Toon Boom Storyboard Pro — Free on request", "Digicel Flipbook — Student license available", "Autodesk Flow — Free"])
            heading("Minimum computer")
            lines(["Processor: Intel 6th gen i5+ or AMD Ryzen 1000+", "Graphics: Nvidia 970+ (4GB+ VRAM) or AMD Radeon R9 290 (4GB+ VRAM)", "RAM: 8GB+", "Storage: 75GB+ free (on top of OS)", "OS: Windows 10 22H2 or newer"])
            heading("Recommended computer")
            lines(["Processor: Intel 11th gen+ or AMD Ryzen 3000+", "Graphics: Nvidia RTX 3000+ (8GB+ VRAM) or AMD Radeon 5000+ (8GB+ VRAM)", "RAM: 16GB+", "Storage: 500GB SSD", "OS: Windows 11"])
            heading("Art supply stores")
            link("Opus Art Supplies", "https://opusartsupplies.com/")
            link("Michaels Canada", "https://canada.michaels.com/")
            link("Amazon", "https://amazon.ca")
            heading("Do")
            lines(["Ask questions — you're here to learn and grow.", "Read assignment instructions carefully and ask your TAs if something is unclear.", "Participate actively in group work.", "Create a LinkedIn profile and start following the industry.", "Respect each other — we're part of a welcoming and diverse community.", "Pay attention to personal hygiene — you're sharing the space with other students."])
            heading("Don't")
            lines(["Don't keep stress to yourself — TAs, instructors, and Student Services are here to support you.", "Don't skip your social life — make time for yourself every week.", "Don't forget to email instructors if you can't submit on time.", "Don't rely on AI for assignments — develop your own creativity and artistic voice."])
        }
    }

    private var digital: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Digital Design")
                .font(.system(.largeTitle, design: .serif))
            Text("Software tutorials, design resources, and creative tools to prepare for your first day")
                .foregroundStyle(Color.stoneLabel)
            heading("Adobe Photoshop & Illustrator")
            Text("Graphic Design Essentials — Start Here").font(.subheadline).foregroundStyle(Color.stoneLabel)
            link("General Adobe Tutorials", "https://www.adobe.com/learn")
            link("The Photoshop Interface", "https://www.youtube.com/watch?v=yqeByrIkrpM")
            link("The Illustrator Interface", "https://www.youtube.com/watch?v=OIatNK6Frf0")
            heading("Adobe Premiere Pro")
            link("Long Intro to Premiere Pro (2hrs)", "https://www.youtube.com/watch?v=oLMdXC_B1vQ")
            link("Quick Intro to Premiere Pro (8mins)", "https://www.youtube.com/watch?v=fgH-aw7tkng")
            link("The Premiere Pro Interface", "https://www.youtube.com/watch?v=bR-n17swu4I")
            heading("Adobe After Effects")
            link("Long Intro to After Effects (1hr)", "https://www.youtube.com/watch?v=jFbRZZmMW7c")
            link("Quick Intro to After Effects (10min)", "https://www.youtube.com/watch?v=hb2bbfiNBXA")
            link("The After Effects Interface", "https://www.youtube.com/watch?v=rBF-KpdBd7s")
            heading("Figma")
            Text("Industry Standard for Interactive Design & Prototyping — Free!").font(.subheadline).foregroundStyle(Color.stoneLabel)
            link("Figma for Beginners (4 parts)", "https://help.figma.com/hc/en-us/sections/4405269443991-Figma-for-beginners-4-parts")
            link("Figma 101 Course", "https://designlab.com/figma-101-course/introduction-to-figma")
            link("13min Figma Crash Course", "https://www.youtube.com/watch?v=jQ1sfKIl50E")
            heading("Creative resources")
            link("Adobe Color", "https://color.adobe.com/")
            link("Coolors", "https://coolors.co/")
            link("Fontjoy", "https://fontjoy.com/")
            heading("Inspiration")
            link("How to Think Like a Graphic Designer", "https://youtu.be/RanfCx18gi4")
            link("Teaching to See", "https://teachingtosee.org/film/TeachingToSee.html")
            link("The Principles of Graphic Design: Color", "https://www.youtube.com/watch?v=_2LLXnUdUIc")
            link("The First Secret of Great Design", "https://youtu.be/9uOMectkCCs")
            link("The Mind Explained – Creativity", "https://www.netflix.com/title/81098586")
            link("Helvetica", "https://watchdocumentaries.com/helvetica/")
            link("Abstract", "https://www.netflix.com/title/80057883")
            link("The Social Dilemma", "https://www.netflix.com/title/81254224")
        }
    }

    private var makeup: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Makeup Design for Film & TV")
                .font(.system(.largeTitle, design: .serif))
            Text("Program preparation, camera requirements, and recommended viewing for Makeup Design students")
                .foregroundStyle(Color.stoneLabel)
            Text("Our VFS Makeup Design department has put together some helpful notes and tips for students leading up to their first day of class.")
                .foregroundStyle(Color.stoneLabel)
            heading("Before Your First Day")
            lines(["Start Taking Pictures. Get used to your camera settings and start cultivating an eye for how lighting affects your photo.", "Take an Art Class. Even if it's just a one-day workshop — it helps build your creative foundation.", "Get Work Experience. Learn to work in a professional environment, with a team. Skills in communication and working under pressure are vital in this industry.", "Save Money. Try to avoid working while at school if possible to get the most out of the program.", "Talk to Professionals. Seek out and speak with actual industry professionals to research more about the realities of this career.", "Clear Your Plate. Have the least amount of personal distractions during your year at VFS."])
            heading("Mirrorless Cameras")
            lines(["Lens: Optical zoom with at least 10X power or fixed lens 50mm+", "Resolution: 20-megapixel resolution", "Flash: Optional — ensure flash can be disabled", "Features: No Skin Softening or Skin Softening can be disabled"])
            heading("Phone Cameras")
            lines(["Apple: iPhone 15 Pro or higher Pro models", "Android: Samsung Galaxy S23, S24", "Features: No Skin Softening or Skin Softening can be disabled"])
            heading("Recommended viewing")
            lines(MakeupFilms.titles)
            heading("From the department")
            Text("Leave your ego at the door. Let your guard down — be vulnerable! The most successful students are the ones who come to this program completely open and willing to learn everything we have to teach them.")
            Text("Amy Van Wormer, Instructor").font(.caption).foregroundStyle(Color.stoneLabel)
            Text("Run away from Instagram/Pinterest and start watching some classic movies! Look at books and magazines! Start getting inspiration from sources other than social media.")
            Text("Rachel Mah, Program Manager").font(.caption).foregroundStyle(Color.stoneLabel)
            Text("Treat the whole year like a job interview, not just a school.")
            Text("Emily Walsh, TA (former VFS Makeup Design student)").font(.caption).foregroundStyle(Color.stoneLabel)
            heading("Reading")
            lines(["Stage Makeup, Richard Corson, James Glavan, Beverly Gore Norcross", "Atlas of Human Anatomy for the Artist, Stephen Rogers Peck", "Human Anatomy for Artists: The Elements of Form, Eliot Goldfinger", "Modelling and Sculpting the Human Figure, Edouard Lanteri", "Color: A Course in Mastering the Art of Mixing Colors, Betty Edwards"])
        }
    }

    private var games: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Game Design")
                .font(.system(.largeTitle, design: .serif))
            Text("Software, hardware, and instructor-curated resource library")
                .foregroundStyle(Color.stoneLabel)
            heading("Specializations")
            lines(["Level Design. Plan and build interactive environments, mission arcs, and world design using Unreal Engine.", "Game Art. Model, texture, and light game assets using Maya, Substance Painter, ZBrush, and Photoshop.", "Coding. Program gameplay systems, AI, UI, and mechanics using C# in Unity and Blueprints in Unreal."])
            heading("Software")
            lines(["Unreal Engine. Primary engine — Level Design, Blueprints, lighting & environments", "Unity (C#). Gameplay programming, physics, UI, animation & multiplayer", "Autodesk Maya. 3D modeling, UV unwrapping, rigging & animation", "Substance Painter. High-to-Low baking, PBR texturing & material authoring", "Adobe Photoshop. Non-destructive asset workflows & 2D game art", "ZBrush. Organic sculpting, hard surface detailing & retopology", "Visual Studio. C# development environment for Unity projects", "Substance Designer. Tiling texture creation & procedural materials"])
            heading("Terms")
            lines(["1 Foundations. Board game theory, game production, storytelling, Level Design 1 (Unreal), Intro to C#, Game Art 1 (Photoshop & Maya).", "2 Core Skills. Digital game theory, Unity 1, Level Design 2, visual scripting in Unreal (Blueprints), Game Art 2 (Substance Painter), mobile & social design.", "3 Team Production. First full team game, combat systems design, Unity 2, Level Design Pipeline, 3D Modelling 1, animation materials & shaders.", "4 Pre-Production. Production docs, project planning, interactive narrative, Unity 3, Level Design 3 (AI & behavior trees), 3D Modelling 2 (ZBrush), environment & lighting.", "5-6 Final Project. Full-scale industry project (solo or team), QA, business of games, cinematics, post-mortem analysis, portfolio & employment prep."])
            heading("Hardware")
            lines(["Gaming-capable laptop or desktop", "16 GB+ RAM (32 GB recommended for ZBrush & Unreal)", "Dedicated GPU — NVIDIA RTX series recommended", "SSD with at least 500 GB free space", "Lab access with pro-grade machines is available on campus"])
            heading("Before you start")
            lines(["Play Games Critically. Analyze why games feel fun. Look at mechanics, level flow, UI, and reward loops — not just graphics.", "Try a Game Engine. Download Unity or Unreal Engine (both free) and follow a beginner tutorial. Even 30 minutes helps build familiarity.", "Play Board Games. Term 1 starts with board game theory. Play different genres — strategy, co-op, party — and think about what makes them work."])
        }
    }

    private var programming: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Programming for Games, Web & Mobile")
                .font(.system(.largeTitle, design: .serif))
            Text("Prep guide: languages, tools, hardware & external resources")
                .foregroundStyle(Color.stoneLabel)
            heading("Languages")
            lines(["C#. Unity development, object-oriented programming, data structures", "C++. Unreal Engine, systems programming, memory management, design patterns", "JavaScript. Web apps, AJAX, server-side scripting, MVC frameworks (React, Vue, Angular)", "HTML5 / CSS3. Responsive web design, dynamic interfaces, template-driven apps", "Python. Cloud computing, Django, Google App Engine, game scripting"])
            heading("Tools")
            lines(["Unity (C#). 3 terms of progressive Unity development — 2D/3D physics, AI, animation, UI, shaders & VFX", "Unreal Engine. Blueprint visual scripting + native C++ development for performance-critical features", "Visual Studio / VS Code. Primary development environments for C#, C++, and web projects", "Git & Version Control. Collaborative workflows, build automation & pipeline management", "Mobile SDKs (iOS & Android). 4 terms of mobile development — sensors, AR, ML, app submission", "Cloud Platforms. Google App Engine, AWS — scalable apps serving millions of users"])
            heading("Terms")
            lines(["1 Fundamentals. Intro to C#, C++, HTML5, operating systems, asset creation tools, pre-production concepts, and technical communications.", "2 Core Development. Unity 1, Unreal Blueprints, data structures & algorithms, math for programmers, JavaScript web apps, Mobile Development 1, OOP in C++.", "3 Team Production. Unity 2 (AI, cameras, weapons), advanced C++, Mobile 2, web app frameworks (React/Vue/Angular), UX design, rapid prototyping, first team game project.", "4 Advanced & Pre-Production. Unity 3, Unreal C++ development, cloud computing, Mobile 3, rendering & shaders, pipelines, pre-production planning for final project.", "5-6 Final Project & Career. Full-scale industry project, Mobile 4 (AR/ML), optimization & debugging, portfolio prep, employment prep with mock interviews."])
            heading("Hardware")
            lines(["Development-capable laptop or desktop", "16 GB+ RAM", "Dedicated GPU recommended for Unreal Engine & Unity", "SSD with at least 500 GB free space", "An Android or iOS device is helpful for mobile testing", "Lab access with pro-grade machines is available on campus"])
            heading("Before you start")
            lines(["Start with C#. Variables, if-statements, loops, and classes. Try Microsoft Learn, Codecademy, or Unity's own beginner scripting tutorials.", "Build a Simple Website. Create a basic HTML/CSS page. Understanding the web stack early will help you in Terms 1-2."])
        }
    }

    private func heading(_ text: String) -> some View {
        Text(text)
            .font(.system(.title3, design: .serif))
            .padding(.top, 8)
    }

    private func lines(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneInk)
            }
        }
    }

    private func link(_ name: String, _ address: String) -> some View {
        Button(name) {
            if let url = URL(string: address) { openURL(url) }
        }
        .tint(Color.welcomeRed)
    }
}

enum MakeupFilms {
    static let titles = [
        "Beetlejuice (1988)", "Driving Miss Daisy (1989)", "Dick Tracy (1990)", "Terminator 2: Judgment Day (1991)",
        "Bram Stoker's Dracula (1992)", "Mrs. Doubtfire (1993)", "Ed Wood (1994)", "Braveheart (1995)",
        "The Nutty Professor (1996)", "Men in Black (1997)", "Elizabeth (1998)", "Topsy-Turvy (1999)",
        "How the Grinch Stole Christmas (2000)", "The Lord of the Rings: The Fellowship of the Ring (2001)",
        "Frida (2002)", "The Lord of the Rings: The Return of the King (2003)",
        "Lemony Snicket's A Series of Unfortunate Events (2004)", "The Chronicles of Narnia (2005)",
        "Pan's Labyrinth (2006)", "La Vie en Rose (2007)", "The Curious Case of Benjamin Button (2008)",
        "Star Trek (2009)", "The Wolfman (2010)", "The Iron Lady (2011)", "Les Misérables (2012)",
        "Dallas Buyers Club (2013)", "The Grand Budapest Hotel (2014)", "Mad Max: Fury Road (2015)",
        "Suicide Squad (2016)", "Darkest Hour (2017)", "Vice (2018)", "Bombshell (2019)",
        "Ma Rainey's Black Bottom (2020)", "The Eyes of Tammy Faye (2021)", "The Whale (2022)",
        "Poor Things (2023)", "The Substance (2024)",
    ]
}
