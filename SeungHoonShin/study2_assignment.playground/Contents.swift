//: Playground - noun: a place where people can play

import UIKit

/*
 protocol Playable
 
 class Song: Playable       단일 음악
 class Album: Playable
 class PlayList: Playble    Album + 단일 음악
 
 */

protocol Playable {
    func play()
}

class Song : Playable {
    let name : String
    let artist : String
    var count : Int = 1
    
    init(name : String, artist: String) {
        self.name = name
        self.artist = artist
    }
    
    /// 노래 재생
    func play() {
        print("PLAY: \(name) By \(artist). count: \(count)")
        count += 1
    }
    /// 노래제목 확인
    func isThisName(_ thatName: String) -> Bool {
        return self.name == thatName
    }
}

class Album : Playable{
    let name : String
    var tracks : Array<Song> = []
    
    init(albumName: String, tracks : Song...) {
        self.name = albumName
        
        for song in tracks {
            self.tracks.append(song)
        }
    }
    
    /// 앨범에 노래 추가
    func append(song: Song){
        self.tracks.append(song)
    }
    
    /// 전곡 재생
    func play() {
        print("ALBUM: \(name) start.")
        for song in tracks{
            song.play()
        }
        print("ALBUM: \(name) end.")
    }
    
    /// 선택 재생
    func playBySongName(_ songName: String) -> Bool{
        for song in tracks{
            if song.isThisName(songName){
                song.play()
                return true
            }
        }
        return false
    }
    
    /// 앨범 제목 확인
    func isThisAlbumName(_ thatName: String) -> Bool {
        return self.name == thatName
    }
    
    /// 앨범에서 노래 찾기
    func searchBySongName(_ songName: String) -> Int? {
        for (index, song) in tracks.enumerated() {
            
            if song.isThisName( songName) {
                print("SEARCH: \(song.name) / ALBUM: \(name)")
                return index
            }
        }
        print("SEARCH FAIL: \(songName) / ALBUM: \(name)")
        return nil
    }
    
    /// 앨범에서 노래 삭제
    func removeBySongName(_ songName: String) -> Bool{
        
        if let index = searchBySongName(songName) {
            tracks.remove(at: index)
            print("REMOVE: \(songName) / ALBUM: \(name)")
            return true
        }
        print("REMOVE FAIL: \(songName) / ALBUM: \(name)")
        return false
    }
    
}



class PlayList : Playable{
    var songs : [Playable] = []
    
    /// 재생목록에 노래 추가
    func append(song: Song){
        songs.append(song)
    }
    
    /// 재생목록에 앨범 추가
    func append(album: Album){
        songs.append(album)
    }
    
    /// 전곡 재생
    func play() {
        for song in songs {
            song.play()
        }
    }
    
    /// 원하는 노래 재생
    func playBySongName(songName: String){
        for item in songs {
            if let song = item as? Song{
                if song.isThisName(songName){
                    song.play()
                    return
                }
            }else if let album = item as? Album {
                if album.playBySongName(songName) {
                    return
                }
            }
        }
        
        print("PLAY FAIL: \(songName)")
    }
    
    /// 원하는 앨범 재생
    func playByAlbumName(albumName: String) {
        
        for item in songs {
            if let item = item as? Album {
                
                if item.isThisAlbumName( albumName) {
                    item.play()
                    return
                }
            }
        }
        print("PLAY FAIL: \(albumName)")
    }
    
    /// 재생목록에서 노래 찾기 
    /// 앨범안에 있을 경우 앨범 인스턴스와 앨범 트랙인덱스 반환
    func searchBySongName(_ songName: String) -> (Int, Playable)? {
        
        for (index, item) in songs.enumerated() {
            
            
            if let album = item as? Album{
                if let trackIndex = album.searchBySongName( songName) {
                    return (trackIndex, item)
                }
                
            }else if let song = item as? Song{
                if song.isThisName(songName){
                    print("SEARCH: \(song.name)")
                    return (index, song)
                }
            }
        }
        print("SEARCH FAIL: \(songName)")
        return nil
    }
    
    /// 재생목록에서 노래 삭제
    func removeBySongName(_ songName: String) -> Bool {
        
        if let (index, item) = searchBySongName(songName) {
            
            if let album = item as? Album {
                album.tracks.remove(at: index)
                return true
            }else if let _ = item as? Song {
                songs.remove(at: index)
                print("REMOVE: \(songName)")
                return true
            }
            
            
        }
        print("REMOVE FAIL: \(songName)")
        return false
    }
}

let 저별: Song = Song(name: "저 별", artist: "헤이즈")
let Decalcomanie: Song = Song(name: "Decalcomanie", artist: "마마무")
let TT: Song = Song(name: "TT", artist: "TWICE")
let 우주 : Song = Song(name: "우주를 줄게", artist: "볼빨간 사춘기")
let 나만: Song = Song(name: "나만 안되는 연애", artist: "볼빨간 사춘기")
let 심술: Song = Song(name: "심술", artist: "볼빨간 사춘기")

저별.play()
우주.play()

var red: Album = Album(albumName: "RED PLANET", tracks: 우주, 나만)

red.append(song: 심술)
red.append(song: TT)
print()
red.play()
red.removeBySongName("TTT")
red.removeBySongName("TT")

var myPlayList: PlayList = PlayList()
myPlayList.append(song: Decalcomanie)
myPlayList.append(song: 저별)
myPlayList.append(album: red)
myPlayList.searchBySongName("심술")
print()
myPlayList.play()








