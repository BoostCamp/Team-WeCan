//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


protocol Playable {
    func play()
}
protocol Removable {
    func removeByName(songName: String) -> Bool
}
protocol Searchable {
    func isThisName( thatName: String) -> Bool
}

struct Song : Playable, Searchable {
    let name : String
    func play() {
        print("PLAY \(name)")
    }
    func isThisName( thatName: String) -> Bool {
        return self.name == thatName
    }
}

class Album : Playable, Removable, Searchable{
    let name : String
    var tracks : Array<Song> = []
    
    init(name: String, trakcs : Song...) {
        self.name = name
        
        for song in tracks {
            self.tracks.append(song)
        }
    }
    
    func append(songName: Song){
        self.tracks.append(songName)
    }
    
    func play() {
        print("\(name) will play")
        for song in tracks{
            song.play()
        }
    }
    func removeByName(songName: String) -> Bool{
        for (index, song) in tracks.enumerated()  {
            if song.isThisName(thatName: songName) {
                tracks.remove(at: index)
                print("Deleted \(songName)")
                return true
            }
        }
        
        return false
    }
    func isThisName( thatName: String) -> Bool {
        //TODO
        return self.name == thatName
    }
    
}

class PlayList : Playable, Removable {
    
    var songs : [Playable] = []
    
    
    
    func play() {
        for song in songs {
            song.play()
        }
    }
    
    func playByAlbum(albumName: String) {
        // TODO
        for item in songs {
            if let item = item as? Album {
                item.isThisName(thatName: albumName)
            }
        }
    }
    
    func removeByName(songName: String) -> Bool {
        
        for (index,item) in songs.enumerated() {
            
            if let songs = item as? Album{
                if songs.removeByName(songName: songName) {
                    return true
                }
            }else if let song = item as? Song{
                
                if song.isThisName(thatName: songName){
                    self.songs.remove(at: index)
                    print("Deleted \(songName)")
                    return true
                }
            }
        
        }
        
        return false
    }
    
}
