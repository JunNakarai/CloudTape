import StoreKit
import SwiftUI

struct SupportDevelopmentView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var store: SupportDevelopmentStore

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("☕ コーヒー1杯分で応援")
                            .font(.headline)

                        Text("CloudTape の開発継続を応援できます。")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)

                    if store.isLoading {
                        HStack {
                            ProgressView()
                            Text("価格を確認しています")
                                .foregroundStyle(.secondary)
                        }
                    } else if let product = store.product {
                        Button {
                            Task {
                                await store.purchaseCoffeeSupport()
                            }
                        } label: {
                            HStack {
                                Text(product.displayPrice)
                                Spacer()
                                Text("応援する")
                            }
                        }
                        .disabled(store.isPurchasing)
                    } else {
                        Button {
                            Task {
                                await store.loadProduct()
                            }
                        } label: {
                            Text("もう一度読み込む")
                        }
                    }

                    if store.isPurchasing {
                        HStack {
                            ProgressView()
                            Text("購入を処理しています")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let errorMessage = store.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    if let statusMessage = store.statusMessage {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                } footer: {
                    Text("購入しても追加機能は解放されません。CloudTape はこれまでどおりすべての基本機能を利用できます。")
                }
            }
            .navigationTitle("開発を応援する")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
            .task {
                await store.loadProduct()
            }
            .alert("CloudTape", isPresented: Binding(
                get: { store.message != nil },
                set: { if !$0 { store.message = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(store.message ?? "")
            }
        }
    }
}
