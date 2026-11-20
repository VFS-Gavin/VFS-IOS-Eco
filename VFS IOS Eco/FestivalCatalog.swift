import Foundation

struct FestivalGroup: Identifiable {
    var region: String
    var detail: String
    var festivals: [NotableFestival]
    var id: String { region }
}

struct NotableFestival: Identifiable {
    var name: String
    var category: String
    var detail: String
    var location: String
    var url: String
    var id: String { name }
}

enum FestivalCatalog {
    static let filmFreewayURL = "https://filmfreeway.com/"
    static let filmFreewayDetail = "FilmFreeway is the industry-standard platform for festival submissions. Create a single project profile with your film, trailer, stills, and director's statement, then submit to VIFF, EIFF, VAFF, TIFF, and thousands of festivals worldwide without re-uploading everything each time."

    static let groups: [FestivalGroup] = [
        FestivalGroup(region: "Vancouver", detail: "Major festivals, youth showcases, and filmmaking competitions in the city.", festivals: [
            NotableFestival(name: "Vancouver International Film Festival (VIFF)", category: "Features & Shorts", detail: "One of Canada's largest film festivals: narrative features, documentaries, and shorts from around the world.", location: "Vancouver, BC", url: "https://viff.org/festival/submissions/"),
            NotableFestival(name: "DOXA Documentary Film Festival", category: "Documentary", detail: "Western Canada's largest documentary festival: bold non-fiction, Justice Forum, and youth programming.", location: "Vancouver, BC", url: "https://doxafestival.ca/"),
            NotableFestival(name: "Vancouver Asian Film Festival (VAFF)", category: "Asian Cinema", detail: "North America's longest-running Asian film festival, with hybrid in-person and online screenings.", location: "Vancouver, BC", url: "https://vaff.org/open-call/"),
            NotableFestival(name: "Vancouver International Youth Film Festival (VIYFF)", category: "Youth Cinema", detail: "Screens work by young and emerging filmmakers, and includes a 72-hour filmmaking workshop and closing gala.", location: "Vancouver, BC", url: "https://www.viyff.org/"),
            NotableFestival(name: "Mighty Asian Moviemaking Marathon (MAMM)", category: "Filmmaking Competition", detail: "VAFF's annual pitch-to-screen challenge. Selected teams shoot a short in 10 days with mentorship and gala screening.", location: "Vancouver, BC", url: "https://vaff.org/mamm/"),
            NotableFestival(name: "Run N Gun (RNG)", category: "Filmmaking Competition", detail: "Vancouver's biggest indie filmmaking competition: write, shoot, and edit a short in one wild weekend.", location: "Vancouver, BC", url: "https://www.rngfest.com/"),
            NotableFestival(name: "Crazy8s Film Competition", category: "Filmmaking Competition", detail: "BC's premier short-film challenge. Six teams pitch, get funded, and shoot in eight days.", location: "Vancouver, BC", url: "https://crazy8s.film/"),
            NotableFestival(name: "Vancouver Latin American Film Festival (VLAFF)", category: "Latin American Cinema", detail: "Celebrates Latin American and Iberian film culture with competitive and audience awards.", location: "Vancouver, BC", url: "https://vlaff.org/"),
            NotableFestival(name: "Vancouver Queer Film Festival (Out On Screen)", category: "LGBTQ2S+ Cinema", detail: "One of the largest queer arts events in Canada, presented by Out On Screen with year-round programming.", location: "Vancouver, BC", url: "https://outonscreen.com/vqff/"),
            NotableFestival(name: "Vancouver International Mountain Film Festival (VIMFF)", category: "Adventure & Outdoor", detail: "Adventure, environmental, and mountain culture films. Great for documentary and action work.", location: "Vancouver, BC", url: "https://vimff.org/"),
            NotableFestival(name: "Reel 2 Real International Film Festival for Youth", category: "Youth & Family", detail: "Culturally diverse cinema for ages 6–19: school programs, workshops, and Youth Filmmakers Showcase.", location: "Vancouver, BC", url: "https://r2r.eventive.org/welcome"),
            NotableFestival(name: "Vancouver Web Fest", category: "Web Series", detail: "Canada's leading web series festival: digital storytelling, episodic work, and industry panels.", location: "Vancouver, BC", url: "https://vancouver-web-fest.com/"),
        ]),
        FestivalGroup(region: "British Columbia", detail: "Festivals across the province, from mountain towns to the Island and Interior.", festivals: [
            NotableFestival(name: "Whistler Film Festival", category: "Features & Shorts", detail: "A major Canadian festival known for discovery, industry access, and the Borsos Competition.", location: "Whistler, BC", url: "https://whistlerfilmfestival.com/"),
            NotableFestival(name: "Victoria Film Festival", category: "Independent Cinema", detail: "Ten days of independent film on Vancouver Island: features, shorts, and Canadian premieres.", location: "Victoria, BC", url: "https://www.victoriafilmfestival.com/"),
            NotableFestival(name: "Kelowna Independent Film Festival", category: "Independent Cinema", detail: "Five-day celebration of independent shorts, features, docs, and 48-hour films in the Okanagan.", location: "Kelowna, BC", url: "https://www.kelownafilmfestival.ca/"),
        ]),
        FestivalGroup(region: "Alberta", detail: "Alberta festivals including Oscar-qualifying shorts and Calgary's indie underground scene.", festivals: [
            NotableFestival(name: "Edmonton International Film Festival (EIFF)", category: "Oscar Qualifying", detail: "Academy Award–qualifying festival. Grand Jury winners in live action, animation, and documentary shorts are eligible for Oscar consideration.", location: "Edmonton, AB", url: "https://edmontonfilmfest.com/"),
            NotableFestival(name: "Calgary Underground Film Festival (CUFF)", category: "Indie & Genre", detail: "Calgary's flagship indie festival for bold, unconventional cinema, plus the annual CUFF.Docs documentary event.", location: "Calgary, AB", url: "https://www.calgaryundergroundfilm.org/call-for-submission/"),
            NotableFestival(name: "Calgary International Film Festival", category: "Features & Shorts", detail: "One of Canada's major regional festivals with competitive sections and industry events.", location: "Calgary, AB", url: "https://www.calgaryfilm.com/"),
        ]),
        FestivalGroup(region: "Canada", detail: "National festivals with major industry visibility: TIFF, Hot Docs, and more.", festivals: [
            NotableFestival(name: "Yorkton Film Festival", category: "Canadian Competition", detail: "North America's longest-running film festival. The Golden Sheaf Awards celebrate Canadian storytelling across 17 categories.", location: "Yorkton, SK", url: "https://yorktonfilm.com/call-for-submissions"),
            NotableFestival(name: "Regina International Film Festival & Awards (RIFFA)", category: "Features, Shorts & Animation", detail: "Saskatchewan's largest film festival: ten competition categories including Animated Short and a dedicated Student Short Film deadline.", location: "Regina, SK", url: "https://riffa.ca/submissions/"),
            NotableFestival(name: "Toronto International Film Festival (TIFF)", category: "Major International", detail: "One of the world's most influential public film festivals: features, shorts, and industry programming.", location: "Toronto, ON", url: "https://www.tiff.net/"),
            NotableFestival(name: "Hot Docs Canadian International Documentary Festival", category: "Documentary", detail: "North America's largest documentary festival. Essential for non-fiction filmmakers.", location: "Toronto, ON", url: "https://www.hotdocs.ca/"),
            NotableFestival(name: "Fantasia International Film Festival", category: "Genre & Animation", detail: "Renowned for genre cinema, animation, and bold international work.", location: "Montreal, QC", url: "https://fantasiafestival.com/"),
            NotableFestival(name: "FIN Atlantic International Film Festival", category: "Atlantic Cinema", detail: "The Atlantic region's flagship festival for Canadian and international features and shorts.", location: "Halifax, NS", url: "https://finfestival.ca/"),
            NotableFestival(name: "imagineNATIVE Film + Media Arts Festival", category: "Indigenous Media", detail: "The world's largest Indigenous film and media arts festival.", location: "Toronto, ON", url: "https://imaginenative.org/"),
            NotableFestival(name: "Banff Centre Mountain Film and Book Festival", category: "Adventure & Mountain Culture", detail: "Globally recognized adventure and mountain culture festival with a major touring program.", location: "Banff, AB", url: "https://banffcentre.ca/film-fest/passes-tickets"),
        ]),
        FestivalGroup(region: "Emerging Filmmakers", detail: "Must-know festivals for directors 24 and under, open to Canadian submissions.", festivals: [
            NotableFestival(name: "NFFTY (National Film Festival for Talented Youth)", category: "Youth & Student", detail: "The world's largest festival for emerging directors aged 24 and under: narrative, documentary, animation, and episodic work.", location: "Seattle, WA", url: "https://www.nffty.org/submit"),
        ]),
        FestivalGroup(region: "Animation & VFX", detail: "The two must-know festivals for animation and VFX portfolio work.", festivals: [
            NotableFestival(name: "Ottawa International Animation Festival (OIAF)", category: "Animation Showcase", detail: "One of the world's leading animation festivals: five days of screenings, industry talks, and workshops in downtown Ottawa. Free to submit.", location: "Ottawa, ON", url: "https://www.animationfestival.ca/festival/entries/"),
            NotableFestival(name: "Annecy International Animation Film Festival", category: "Animation: Graduation Films", detail: "The world's most prestigious animation festival. Student work has its own dedicated Graduation Films category.", location: "Annecy, France", url: "https://www.annecyfestival.com/en/news/film-submissions-are-open"),
        ]),
        FestivalGroup(region: "International", detail: "Major international festivals with student- and emerging-filmmaker-friendly entry paths.", festivals: [
            NotableFestival(name: "Clermont-Ferrand International Short Film Festival", category: "Short Films", detail: "The world's largest short film festival, accredited by the Oscars, BAFTA, and the César Awards.", location: "Clermont-Ferrand, France", url: "https://www.lecourt-clermont.org/en/pros/submit-a-film/"),
            NotableFestival(name: "Slamdance Film Festival", category: "Indie & First-Time Directors", detail: "A filmmaker-run festival spotlighting emerging and first-time directors, with a Digital, Interactive & Gaming category.", location: "Los Angeles, CA", url: "https://slamdance.com/festival-submit/"),
        ]),
    ]
}
