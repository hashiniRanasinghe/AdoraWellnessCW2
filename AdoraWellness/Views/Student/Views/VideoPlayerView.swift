//
//  VideoPlayerView.swift
//  AdoraWellness
//
//  Created by Hashini Ranasinghe on 2025-08-27.
//

import AVFoundation
import AVKit
import Combine
import SwiftUI

struct VideoPlayerView: View {
    let lesson: Lesson
    @Environment(\.dismiss) private var dismiss
    @StateObject private var playerViewModel = VideoPlayerViewModel()
    @State private var isFullScreen = false

    var body: some View {
        //swiftUI container that gives info abt its size and position
        GeometryReader { geometry in  //calculate the height of the video player dynamically
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()  //makes the background fill the entire screen,

                VStack(spacing: 0) {
                    headerView

                    videoPlayerSection
                        .frame(height: geometry.size.width * 9 / 16)

                    lessonDetailsSection

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            playerViewModel.loadVideo(from: lesson.videoURL)
        }
        .onDisappear {
            playerViewModel.cleanup()
        }
        .fullScreenCover(isPresented: $isFullScreen) {
            FullScreenVideoView(player: playerViewModel.player)
        }
    }

    private var headerView: some View {
        HStack(spacing: 16) {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(lesson.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }

    private var videoPlayerSection: some View {
        ZStack {
            Color.black

            if let player = playerViewModel.player {
                ZStack {
                    VideoPlayer(player: player)

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                isFullScreen = true
                            }) {
                                Image(
                                    systemName:
                                        "arrow.up.left.and.arrow.down.right"
                                )
                                .font(.title2)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                                .foregroundColor(.white)
                                .padding(12)
                            }
                        }
                    }
                }
            } else if playerViewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                        .tint(Color(red: 0.4, green: 0.3, blue: 0.8))

                    Text("Loading video...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            } else if playerViewModel.hasError {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Unable to load video")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)

                    if !playerViewModel.errorMessage.isEmpty {
                        Text(playerViewModel.errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    Button("Try Again") {
                        playerViewModel.loadVideo(from: lesson.videoURL)
                    }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.4, green: 0.3, blue: 0.8))
                    .cornerRadius(16)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "play.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.white)

                    Text("Video unavailable")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                }
            }
        }
        .cornerRadius(12)
        .padding(.horizontal, 24)
    }

    private var lessonDetailsSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(lesson.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)

                            Text(lesson.subtitle)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    HStack(spacing: 24) {
                        HStack(spacing: 6) {
                            Image(systemName: "clock")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text("\(lesson.duration) min")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "flame")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text("\(lesson.calories) cal")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 14))
                                .foregroundColor(
                                    Color(red: 0.4, green: 0.3, blue: 0.8))
                            Text(lesson.level)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                        }

                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("About This Lesson")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(lesson.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }

                if !lesson.equipment.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Equipment Needed")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)

                        VStack(alignment: .leading, spacing: 8) {

                            //loops through lesson.equipment array
                            ForEach(lesson.equipment, id: \.self) {
                                equipment in  //each element is uniquely identified by its own value

                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(
                                            Color(
                                                red: 0.4, green: 0.3, blue: 0.8)
                                        )

                                    Text(equipment)
                                        .font(.system(size: 16))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                }

                Color.clear.frame(height: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
    }
}

//full screen video view
struct FullScreenVideoView: View {
    let player: AVPlayer?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = player {
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
            }

            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                Spacer()
            }
        }
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(lesson: Lesson.sampleLessons[0])
    }
}
